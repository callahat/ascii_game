class GameController < ApplicationController
	before_filter :authenticate, :except => ['main', 'feature', 'demo', 'world']

	layout 'main'

		# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post,:only => [ :do_heal, :do_choose, :do_train ],
													:redirect_to => { :action => :feature }

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
			elsif params[:id] == 'east' && WorldMap.find(:first, :conditions => ['bigxpos = ? and bigypos = ?', @pc[:bigx] + 1, @pc[:bigy]])
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
		if session[:player].nil?
			redirect_to :action => 'demo'
		elsif session[:player_character].nil?
			redirect_to :controller => 'character', :action => 'choose' #???
		elsif session[:player_character].battle
			redirect_to :controller => 'battle', :action => 'battle'
		else #check for current event
			@pc = session[:player_character].reload
			@pc.reload
			p (@current_event = @pc.current_event)

			if (@events = session[:ev_choices])
				render :action => 'choose'
			elsif (@current_event = @pc.current_event)
				if @current_event.completed == EVENT_INPROGRESS #already have an event in progress
					exec_event(@current_event)
				elsif @current_event.completed == EVENT_FAILED
					@current_event.destroy
					redirect_to :action => 'main'
				else #skipped or completed, get the next event for the feature
					#figure out the next event, wether user chooses, is assigned, or there is nothing else
					next_event_helper(@current_event)
				end
			elsif params[:id]
				#start new current event
				@current_event = CurrentEvent.make_new(session[:player_character], params[:id])
				if @pc.turns < @current_event.location.feature.action_cost
					flash[:notice] = 'Too tired for that, out of turns.'
					redirect_to :action => 'main'
				else
					PlayerCharacter.transaction do
						@pc.lock!
						@pc.turns -= @current_event.location.feature.action_cost
						@pc.save!
					end
					next_event_helper(@current_event)
				end
			else #no current event and no feature id
				redirect_to :action => 'main'
			end
		end
	end

	def do_choose
		@current_event = session[:player_character].current_event
		if Event.exists?(params[:id]) && session[:ev_choices].index(Event.find(params[:id])) > -1
			@current_event.update_attribute(:event_id, params[:id])
			session[:ev_choices] = nil
			exec_event(@current_event)
		else #id is null, player didnt choose any event, or they attempted a hack
			@current_event.update_attribute(:completed, EVENT_SKIPPED)
			session[:ev_choices] = nil
			flash[:notice] = 'You slink on by without anything interesting happening.'
			redirect_to :action => 'complete'
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
		@current_event = session[:player_character].current_event
		@next,@events = @current_event.complete
		
		if @next.nil?
			@current_event.destroy
			redirect_to :action => 'main'
		else
			redirect_to :action => 'feature'
		end
	end
	
	def spawn_kingdom
		@kingdom = Kingdom.new
	end
	
	def do_spawn
		@wm = session[:last_action]
		
		@kingdom, @msg = Kingdom.spawn(session[:player_character], @wm, params[:kingdom][:name])
		if @kingdom
			render :action => 'spawn'
		else
			flash[:notice] = @msg
			session[:completed] = true
			redirect_to :controller => '/game', :action => 'complete'
		end
	end
	
protected
	def exec_event(ce)
		p ce.inspect
		@direction, @completed, @message = ce.event.happens(session[:player_character])
		ce.update_attribute(:completed, @completed)
		
		if @direction
			redirect_to @direction
		else
			render 'game/complete'
		end
	end
	
	def next_event_helper(ce)
		p "Next event helper"
		@next, @it = ce.next_event
		
		if @next.nil?
			flash[:notice] = "Nothing happens"
			@current_event.destroy
			redirect_to :action => 'main'
		elsif @it.class == Array
			ce.update_attributes(:priority => @next)
			@events = @it
			session[:ev_choices] = @events.dup #simplify whats a valid choice or not
			render :action => 'choose'
		else #must be an event
			ce.update_attributes(:event_id => @it.id, :priority => @next)
			exec_event(ce)
		end
	end
end
