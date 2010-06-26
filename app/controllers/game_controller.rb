class GameController < ApplicationController
	before_filter :authenticate, :except => ['main', 'feature']

	layout 'main'

		# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post,:only => [ :do_heal, :do_choose, :do_train, :do_spawn ],
													:redirect_to => { :action => :feature }

	def main
		flash[:notice] = flash[:notice]
		
		if session[:player_character].nil?
			redirect_to :controller => 'character'
			return
		end
		
		#this is the main game controller. Find out where the person is,
		if session[:player_character].present_kingdom
			@where = session[:player_character].present_level
		elsif session[:player_character].present_world
			@where = [session[:player_character].present_world,
								session[:player_character].bigx,
								session[:player_character].bigy]
		else
			flash[:notice] = 'You find yourself floating in empty space. There is nothing of interest anywhere.'
		end
	end

	def leave_kingdom
		if session[:player_character].present_level && session[:player_character].present_level.level == 0
			PlayerCharacter.transaction do
				session[:player_character].lock!
				session[:player_character].in_kingdom = nil
				session[:player_character].kingdom_level = nil
				session[:player_character].save!
			end
			@message = "Left the kingdom"
		end
		
		redirect_to :controller => 'game', :action => 'main'
	end

	#moving in the world, by just walking. no need for an event
	def world_move
		@pc = session[:player_character]
		PlayerCharacter.transaction do
			@pc.lock!
		
			if params[:id] == 'north' && WorldMap.exists?(:bigxpos => @pc[:bigx], :bigypos => @pc[:bigy] -1)
				flash[:notice] = "Moved North"
				@pc[:bigy] -= 1
			elsif params[:id] == 'south' && WorldMap.exists?(:bigxpos => @pc[:bigx], :bigypos => @pc[:bigy] +1)
				flash[:notice] = "Moved South"
				@pc[:bigy] += 1
			elsif params[:id] == 'west' && WorldMap.exists?(:bigxpos => @pc[:bigx] - 1, :bigypos => @pc[:bigy])
				flash[:notice] = "Moved West"
				@pc[:bigx] -= 1
			elsif params[:id] == 'east' && WorldMap.exists?(:bigxpos => @pc[:bigx] + 1,:bigypos => @pc[:bigy])
				flash[:notice] = "Moved East"
				@pc[:bigx] += 1
			else
				flash[:notice] = "Unknown/invalid direction"
			end
			@pc.save!
		end
		redirect_to :controller => 'game', :action => 'main'
	end

	#deal with the feature, set up the session feature_event chain
	def feature
		flash[:notice] = flash[:notice]
		if session[:player].nil?
			redirect_to login_url()
		elsif session[:player_character].nil?
			redirect_to :controller => 'character', :action => 'choose_character'
		elsif session[:player_character].reload && session[:player_character].battle
			redirect_to :controller => 'game/battle', :action => 'battle'
		else #check for current event
			@pc = session[:player_character]

			if (@events = session[:ev_choices])
				render :file => 'game/choose.rhtml', :layout => true
			elsif @current_event = @pc.current_event
				if @current_event.completed == EVENT_INPROGRESS #already have an event in progress
					exec_event(@current_event)
				elsif @current_event.completed == EVENT_FAILED
					@current_event.destroy
					redirect_to :controller => 'game', :action => 'main'
				else #skipped or completed, get the next event for the feature
					next_event_helper(@current_event)
				end
			elsif params[:id]
				#start new current event
				@current_event = CurrentEvent.make_new(session[:player_character], params[:id])
				if @pc.turns < @current_event.location.feature.action_cost
					@current_event.destroy
					flash[:notice] = 'Too tired for that, out of turns.'
					redirect_to :controller => 'game', :action => 'main'
				else
					PlayerCharacter.transaction do
						@pc.lock!
						@pc.turns -= @current_event.location.feature.action_cost
						@pc.save!
					end
					next_event_helper(@current_event)
				end
			else #no current event and no feature id
				redirect_to :controller => 'game', :action => 'main'
			end
		end
	end

	def do_choose
		@current_event = session[:player_character].current_event
		if Event.exists?(params[:id]) && session[:ev_choices].index(Event.find(params[:id]))
			@current_event.update_attribute(:event_id, params[:id])
			session[:ev_choices] = nil
			exec_event(@current_event)
		elsif params[:id]
			flash[:notice] = "Invalid choice"
			@events = session[:ev_choices]
			@pc = session[:player_character]
			render :file => 'game/choose.rhtml', :layout => true
		else#id is null, player didnt choose any event, or they attempted a hack
			@current_event.update_attribute(:completed, EVENT_SKIPPED)
			session[:ev_choices] = nil
			flash[:notice] = 'You slink on by without anything interesting happening.'
			redirect_to :controller => 'game', :action => 'complete'
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
		redirect_to :controller => 'game', :action => 'main'
	end
	
	def complete
		@current_event = session[:player_character].current_event
		@next,@events = @current_event.complete
		
		if @next.nil?
			@current_event.destroy
			redirect_to :controller => 'game', :action => 'main'
		else
			redirect_to :controller => 'game', :action => 'feature'
		end
	end
	
	def spawn_kingdom
		@kingdom = Kingdom.new
	end
	
	def do_spawn
		@pc = session[:player_character]
		redirect_to(:action=>'feature') && return \
			unless @pc.current_event && @pc.current_event.event.class == EventSpawnKingdom
		@wm = @pc.current_event.location
		
		@kingdom, @msg = Kingdom.spawn_new(session[:player_character], params[:kingdom][:name], @wm)
		if @kingdom
			render :controller => 'game', :action => 'spawn_kingdom'
		else
			flash[:notice] = @msg
			session[:completed] = true
			redirect_to :controller => 'game', :action => 'complete'
		end
	end
	
protected
	def exec_event(ce)
		@direction, @completed, @message = ce.event.happens(session[:player_character])
		ce.update_attribute(:completed, @completed)
		session[:player_character].reload
		
		if @direction
			flash[:notice] = @message
			redirect_to @direction
		else
			render :file => 'game/complete.rhtml', :layout => true
		end
	end
	
	def next_event_helper(ce)
		@next, @it = ce.next_event
		
		if @next.nil?
			flash[:notice] = "Nothing happens"
			@current_event.destroy
			redirect_to :controller => 'game', :action => 'main'
		elsif @it.class == Array
			ce.update_attributes(:priority => @next)
			@events = @it
			@pc = session[:player_character]
			session[:ev_choices] = @events.dup #simplify whats a valid choice or not
			render :file => 'game/choose.rhtml', :layout => true
		else #must be an event
			ce.update_attributes(:event_id => @it.id, :priority => @next)
			exec_event(ce)
		end
	end
end
