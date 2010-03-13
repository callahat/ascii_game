class GameController < ApplicationController
	before_filter :authenticate, :except => ['main', 'feature', 'demo', 'world']

	layout 'main'

		# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_heal, :do_choose, :do_train ],				 :redirect_to => { :action => :feature }
	
	def main
		flash[:notice] = flash[:notice]
		
		if session[:player_character].nil?
			redirect_to :controller => 'character'
			return
		end
		
		session[:player_character].reload
		#this is the main game controller. Find out where the person is,
		if !session[:player_character].present_kingdom.nil?
			redirect_to :action => 'kingdom'
		elsif !session[:player_character].present_world.nil?
			redirect_to :action => 'world'
		else
			flash[:notice] = 'You find yourself floating in empty space. There is nothing of interest anywhere.'
		end
	end

	def demo
	end

	#Exploring the kingdom
	def kingdom
		@empty_image = Feature.find(:first, :conditions => ['kingdom_id = ? and player_id = ? and name = ?', -1, -1, "\nEmpty"]).image.image_text
		if session[:player_character].present_level.nil?
			session[:player_character].kingdom_level = PlayerCharacter.find(session[:player_character][:id]).present_kingdom.levels.find(:first, :conditions => ['level = ?', '0']).id
			session[:player_character].save
		end

		@level = session[:player_character].present_level
		@y,@x = 0,0
	end

	def leave_kingdom
		PlayerCharacter.transaction do
			session[:player_character].lock!
			session[:player_character].in_kingdom = nil
			session[:player_character].kingdom_level = nil
			session[:player_character].save!
		end

		@message = "Left the kingdom"
		redirect_to :action => 'main'
	end

	#exploring the world
	def world
		@empty_image = Feature.find(:first, :conditions => ['kingdom_id = ? and player_id = ? and name = ?', -1, -1, "\nEmpty"]).image.image_text
		@world = session[:player_character].present_world
		print session[:player_character].bigx.to_s + " " + session[:player_character].bigy.to_s
		@x,@y = 1,1
		
		@north = WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', session[:player_character][:bigx], session[:player_character][:bigy] -1])
		@south = WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', session[:player_character][:bigx], session[:player_character][:bigy] +1])
		@east = WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', session[:player_character][:bigx] + 1, session[:player_character][:bigy]])
		@west = WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', session[:player_character][:bigx] - 1, session[:player_character][:bigy]])
	end
	
	#moving in the world, by just walking. no need for an event
	def world_move
		@pc = session[:player_character]
		PlayerCharacter.transaction do
			@pc.lock!
		
			if params[:id] == 'north' && WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', @pc[:bigx], @pc[:bigy] -1])
				flash[:notice] = "Moved North"
				@pc[:bigy] -= 1
			elsif params[:id] == 'south' && WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', @pc[:bigx], @pc[:bigy] +1])
				flash[:notice] = "Moved South"
				@pc[:bigy] += 1
			elsif params[:id] == 'west' && WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', @pc[:bigx] - 1, @pc[:bigy]])
				flash[:notice] = "Moved West"
				@pc[:bigx] -= 1
			elsif params[:id] == 'east' && WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', @pc[:bigx] + 1, @pc])
				flash[:notice] = "Moved East"
				@pc[:bigx] += 1
			else
				flash[:notice] = "Unknown/invalid direction"
			end
			@pc.save!
		end
		redirect_to :action => 'world'
	end

	#deal with the feature, set up the session feature_event chain
	def feature
		flash[:notice] = flash[:notice]
		
		#yeah, temporary redirection hack.
		if session[:player].nil? || session[:player_character].nil?
			redirect_to :action => 'demo'
			return
		end

		if params[:id].nil? && session[:fe_curpri].nil?
			redirect_to :action => 'main'
			return false
		end
		
		if session[:current_event].class == Event
			redirect_to :action => 'exec_event'
			return
		end
 #using the session to keep track of the last actions will leave a back door. Same goes for any other
 #event chain they get caught up in. This is accetable, but in the future it might be a good idea
 #to just have the last actions, current feature, etc, be a new database table.
 #also check the last action against the current action. If current action is not null or the same, new FE chain
		if session[:last_action].nil? ||
			 ((session[:fe_chain].nil? || session[:fe_curpri] == 42 || session[:fe_curpri].nil?) &&
			 (params[:id] && params[:id] != session[:last_action].id))
			#make sure player has enough "moves" left
		PlayerCharacter.transaction do
				session[:player_character].lock!
			
				if session[:player_character].in_kingdom && params[:id]
					@last_action = LevelMap.find(params[:id])
				else
					@last_action = WorldMap.find(params[:id])
				end
			
				if session[:player_character].turns < @last_action.feature.action_cost
					flash[:notice] = 'Too tired for that, out of turns.'
					session[:player_character].save!
					redirect_to :action => 'main'
					return
				else
					session[:player_character].turns -= @last_action.feature.action_cost
					session[:player_character].save!
				end
			end
			print "\ncreating a new feature event chain"
			session[:last_action] = @last_action
			session[:fe_chain] = session[:last_action].feature.feature_events
			session[:fe_curpri] = -1
			
			#get the first priority level
			#when this event is completed sucessfully, then the protected controller will advance to the next priority.
			if !advance_fe_curpri
				redirect_to :action => 'main'
				return
			end
		end
		
		#prune the events that have already been done, do not include events that are not in the range
		@fes = prune_done_events(session[:fe_chain].find(:all, :conditions => ['priority = ? and choice = ? and chance > ?', session[:fe_curpri], false, rand(100)] ))
		@choices = prune_done_events( session[:fe_chain].find(:all, :conditions => ['priority = ? and choice = ? and chance > ?', session[:fe_curpri], true, rand(100)] ))
		
		print "\n" + @fes.size.to_s + " compulsories, " + @choices.size.to_s + " choices"
		
		if @fes.size > 0 && @choices.size > 0
			#There are a number of mandatory and choice events
			@pick = rand(@fes.size + @choices.size)
			if @pick < @fes.size
				session[:current_event] = @fes[@pick].event
				redirect_to :action => 'exec_event'
			else
				session[:current_event] = @choices
				redirect_to :action => 'choose'
				return
			end
		elsif @fes.size > 0 && @choices.size == 0
			session[:current_event] = @fes[rand(@fes.size).to_i].event
			redirect_to :action => 'exec_event'
			return
		elsif @fes.size == 0 && @choices.size > 0
			@rnd = 100 - rand(100)
			session[:current_event] = []
			for choice in @choices
				if choice.chance >= @rnd
					session[:current_event] << choice
				end
			end
			redirect_to :action => 'choose'
			return
		else
			#this could happen if all events t this priority were limited and all done with regards to the character.
			#in that case, skip this priority level
			flash[:notice] = 'Nothing happened (no more events for this feature?)'
			
			if !advance_fe_curpri
				redirect_to :action => 'main'
				return
			end
			
			redirect_to :action => 'feature'
		end
	end

	def choose
		@pc = session[:player_character]
		if session[:current_event].class == Array
			@feature_events = session[:current_event]
			if @feature_events.nil? || @feature_events.size == 0
				flash[:notice] = 'Nothing of interest happens.'
				session[:choose_none] = false
				redirect_to :action => 'complete'
			end
		else
			redirect_to :action => 'exec_event'
		end
	end

	def do_choose
		print "\ndo_choose, current event class: " + session[:current_event].class.to_s
		
		if session[:current_event].class != Array
			redirect_to :action => 'exec_event'
		elsif params[:id]
			print session[:current_event].class.to_s + "	first\n"
			session[:current_event] = Event.find(params[:id])
			print session[:current_event].class.to_s + "	second\n"
			redirect_to :action => 'exec_event'
		else #id is null, player didnt choose any event
			flash[:notice] = 'You slink on by without anything interesting happening.'
			
			session[:choose_none] = true
			redirect_to :action => 'complete'
		end
	end
	
	def exec_event
		@event = session[:current_event]
		p @event.inspect
		@direction, @completed, @message = @event.happens(session[:player_character])
		if @direction
			redirect_to @direction
		else
			render :action => '../complete'
		end
	end
	
	def wave_at_pc
		@pc = PlayerCharacter.find(session[:current_event].event_player_character.player_character_id)
		Illness.spread(session[:player_character], @pc, SpecialCode.get_code('trans_method','air') )
		Illness.spread(@pc, session[:player_character], SpecialCode.get_code('trans_method','air') )
	end
	
	def make_camp
		@pc = session[:player_character]
		if session[:current_event].nil?
			Health.transaction do
				@pc.health.lock!
				@hp_gain = minimum((@pc.health.base_HP * (rand() /10.0 + 0.07)).to_i, @pc.health.base_HP - @pc.health.HP)
				@mp_gain = minimum((@pc.health.base_MP * (rand() /10.0 + 0.03)).to_i, @pc.health.base_MP - @pc.health.MP)
				@pc.health.HP += @hp_gain
				@pc.health.MP += @mp_gain
			
			flash[:notice] = 'Rested'
				if @pc.health.base_HP == @pc.health.HP
					if @pc.health.wellness == SpecialCode.get_code('wellness','dead')
					flash[:notice] += ', and rose from the grave'
				end
					if session[:player_character].illnesses.size == 0
						@pc.health.wellness = SpecialCode.get_code('wellness','alive')
				else
						@pc.health.wellness = SpecialCode.get_code('wellness','diseased')
				end
			end
				@pc.health.save!
			end
			PlayerCharacter.transaction do
				@pc.lock!
				@pc.turns -= 1
				@pc.save!
			end
			if @hp_gain > 0
				flash[:notice] += ', gained ' + @hp_gain.to_s + ' HP'
			end
			if @mp_gain > 0
				flash[:notice] += ', gained ' + @mp_gain.to_s + ' MP'
			end
		else
			flash[:notice] = "Cannot rest while in midst of action!"
		end
		session[:player_character] = @pc
		redirect_to :controller => '/game', :action => 'main'
	end
	
	def completeA
		@pc = session[:player_character]
		session[:regicide] = false
		create_accession_notice("The former king was slain by " + @pc.name + ". The realm is left without a king.",@pc.present_kingdom)
		redirect_to :action => 'complete'
	end
	
	def complete
		#routine that cleans up when an event is sucessfully completed. Note that if an event is not
		if session[:completed]
			print "COMPLETE" + SpecialCode.get_text('event_rep_type',session[:current_event].event_rep_type)
			
			#No lock necessary, these rows will only be created and counted, never destroyed (except for in a refresh)
			if session[:current_event].event_rep_type != SpecialCode.get_code('event_rep_type','unlimited')
				#if its not an unlimited event rep type, then lg this event as beign completed.
				@done_event = DoneEvent.new
				@done_event.event_id = session[:current_event].id
				@done_event.player_character_id = session[:player_character][:id]
				@done_event.datetime = Time.now
				if session[:player_character].in_kingdom && !session[:spawn_kingdom]
					@done_event.level_map_id = session[:last_action].id
				else
					session[:spawn_kingdom] = false
					@done_event.world_map_id = session[:last_action].id
				end
				
				@done_event.save
			end
			
			#Requirement for a quest the player is on? 
			#explore quest
			LogQuestExplore.complete_req(session[:player_character][:id], session[:current_event].id)

			if session[:battle_gold]
				@gold = session[:battle_gold]
				#divy out the taxes if in a kingdom
				@kingdom = session[:player_character].present_kingdom
				if session[:player_character].in_kingdom
					@tax = (@gold * (@kingdom.tax_rate/100.0)).to_i
					Kingdom.pay_tax(@tax, @kingdom)
					
					@gold -= @tax
				end
			
				#award any gold and items to the player
		PlayerCharacter.transaction do
					session[:player_character].lock!
					session[:player_character][:gold] += @gold
					session[:player_character].save!
				end
			end
			
			if session[:current_event].class == EventStormGate
				#Player enters castle if sucessfully stormed
		PlayerCharacter.transaction do
					session[:player_character].lock!
					session[:player_character][:in_kingdom] = session[:current_event].level.kingdom_id
					session[:player_character][:kingdom_level] = session[:current_event].thing_id
				
					#create kingdom notice of a player storming the gate
					create_storm_gate_notice(session[:player_character].name + " stormed the gates and gained entry to the kingdom.")
				
					session[:storm_gate] = nil
					session[:player_character].save!
				end
			end
			
			for booty in session[:battle_item].to_a do
				PlayerCharacterItem.update_inventory(session[:player_character].id,booty.id,1)
			end
			
			if session[:regicide]
				session[:keep_fighting] = nil
				session[:regicide] = nil
		@kingdom = session[:player_character].present_kingdom
		Kingdom.transaction do
			@kingdom.lock!
					@kingdom.player_character_id = session[:player_character][:id]
					@kingdom.save!
				end
					create_accession_notice("The former king has been violently overthrown by " + session[:player_character].name + " who has assumed the crown.", @kingdom)
				end
			
			#completed, the feature event chain will be broken, and it will just go back to main, and no further
			session[:completed] = nil	#reset the completed bit
			session[:current_event] = nil
			
			if !advance_fe_curpri 
				redirect_to :action => 'main' 
				return
			end
			
			redirect_to :action => 'feature'
		elsif session[:choose_none]
			print "\nChose none of the events"
		
			session[:keep_fighting] = nil
			session[:regicide] = nil
			
			session[:choose_none] = nil	#reset the completed bit
			session[:current_event] = nil
		
			if !advance_fe_curpri 
				redirect_to :action => 'main' 
				return
			end
			
			redirect_to :action => 'feature'
		else
			#otherwise, the event was not completed sucessfully, so abort the FE chain and go back to the map
			#unless this is a battle, then redirect to an attempt at running away if there are any 
			print "INCOMPLETE"
			
			if session[:storm_gate]
				#Player failed to break into the kingdom
				create_storm_gate_notice(session[:player_character].name + " attempted to storm the gates, but was repelled by the guards.")
				
				session[:storm_gate] = nil
			end
			
			session[:current_event] = nil
			session[:fe_curpri] = nil
			
			redirect_to :action => 'main' 
		end
	end
	
protected
	def create_storm_gate_notice(text)
		#create kingdom notice of a player storming the gate
		@notice = KingdomNotice.new
		@notice.kingdom_id = session[:storm_gate]
		@notice.shown_to = SpecialCode.get_code('shown_to','king')
		@notice.datetime = Time.now
		@notice.text = text
		@notice.signed = "Captain of the Guard"
		@notice.save
	end

	def prune_done_events(fes)
		@active_events = []
		
		if session[:player_character].in_kingdom
			accessor = 'level_map_id'
		else
			accessor = 'world_map_id'
		end
		
		for fe in fes
			#print "\nevent ID:" + fe.event.id.to_s + "\nrep type:" + SpecialCode.get_text('event_rep_type',fe.event.event_rep_type)
			if fe.event.event_rep_type == SpecialCode.get_code('event_rep_type','limited')
				if DoneEvent.find(:all, :conditions => [accessor + ' = ? and event_id = ?', session[:last_action].id, fe.event.id]).size < fe.event.event_reps
					@active_events << fe
				end
			elsif fe.event.event_rep_type == SpecialCode.get_code('event_rep_type','limited_per_char')
				if DoneEvent.find(:all, :conditions => ['player_character_id = ? and ' + accessor + ' = ? and event_id = ?', session[:player_character][:id], session[:last_action].id, fe.event.id]).size < fe.event.event_reps
					@active_events << fe
				end
			elsif fe.event.event_rep_type == SpecialCode.get_code('event_rep_type','unlimited')
				@active_events << fe
			end
		end	
	
		return @active_events
	end

	def advance_fe_curpri
		session[:fe_curpri] = session[:fe_chain].find(:first, :conditions => ['priority > ?', session[:fe_curpri]])
		print "\nCurrent priority1:" + session[:fe_curpri].to_s + " " + session[:fe_curpri].nil?.to_s
		#are there more featuers in the chain?
		if session[:fe_curpri].nil?
			session[:fe_chain] = nil
			return false
		end
		session[:fe_curpri] = session[:fe_curpri].priority
		print "\nCurrent priority2:" + session[:fe_curpri].to_s
		return true
	end
end
