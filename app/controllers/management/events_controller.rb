class Management::EventsController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update, :update_sub_event, :arm_event ],				 :redirect_to => { :action => :index }


	#**********************************************************************
	#EVENT MANAGEMENT
	#**********************************************************************
	public
	def index
		#design events
		@events = Event.get_page(params[:page], session[:player][:id], session[:kingdom][:id])
	end

	def show
		@event = Event.find(params[:id])
	end

	def new
		@event = Event.new
		get_event_types
		@event_rep_types = SPEC_CODET['event_rep_type'].to_a
		p @event_rep_types.inspect
	end

	def create
		@event = Event.new(params[:event])
		@event.player_id = session[:player][:id]
		@event.kingdom_id = session[:kingdom][:id]
		
		@event.cost = 500
		
		get_event_types
		@event_rep_types = SPEC_CODET['event_rep_type'].to_a

		if @event.save
			flash[:notice] = @event.name + ' was successfully created.'
			session[:event] = @event
			redirect_to :action => 'edit_sub_event'
			#redirect_to :action => 'new_sub_event'
		else
			render :action => 'new'
		end
	end

	def edit
		@event = Event.find(params[:id])

		session[:event] = @event
		
		get_event_types
		@event_rep_types = SPEC_CODET['event_rep_type'].to_a
	end

	def update
		@event = Event.find(params[:id])
		@old_type = @event.event_type	#what is this old type for?
		if !verify_event_not_in_use || !verify_event_owner
			redirect_to :action => 'index'
			return
		end

		get_event_types
		@event_rep_types = SPEC_CODET['event_rep_type'].to_a

		h = {}
		h[:name] = params[:event][:name]
		h[:event_rep_type] = params[:event][:event_rep_type]
		h[:event_reps] = params[:event][:event_reps]
		h[:event_type] = params[:event][:event_type]
		
		if @event.update_attributes(params[:event])
			flash[:notice] = @event.name + ' was successfully updated.'
			session[:event] = @event
			redirect_to :action => 'edit_sub_event'
		else
			render :action => 'edit'
		end
	end

	def edit_sub_event
		#huge if elsif chain to deal with the different possible sub events.
		#structure will need to be mimiced in the view. And in the create_sub_event
		@event = session[:event]

		pop_sub_event
	end


	def update_sub_event
		@event = session[:event]

		if !verify_event_not_in_use || !verify_event_owner
			redirect_to :action => 'index'
			return
		end
		
		if !verify_valid_event_sub_params
			redirect_to :action => 'edit_sub_event'
			return
		end
		pop_sub_event
		@event_sub.event_id = @event.id
		if @stat || @health
			if @event_sub.save && @stat.valid? & @health.valid?
				@stat.owner_id = @event_sub.id
				@health.owner_id = @event_sub.id
				@stat.save
				@health.save
				@extras = true
			else
				@extras = false
			end
		else
			@extras = true
		end
		
		
		if @event_sub.update_attributes(params[:event_sub]) && @extras
			flash[:notice] = 'Event consequence updated succesfully'
			
			calc_sub_event_cost
			
			#update event cost
			if @event.event_rep_type == SpecialCode.get_code('event_rep_type','unlimited') || @event.event_reps > 9000
				@event.cost = 500 + @cost * 9000
			elsif @event.event_rep_type == SpecialCode.get_code('event_rep_type','limited') 
				@event.cost = 500 + @cost * @event.event_reps * 2
			else
				@event.cost = 500 + @cost * @event.event_reps * 5
			end
			
			if @event.save
				flash[:notice] += '<br/>event cost updated.'
				redirect_to :action => 'index'
			else
				flash[:notice] += '<br/>event cost failed to update.'
				render :action => 'edit_sub_event'
			end
		else
			flash[:notice] = 'Error in updating the event'
			render :action => 'edit_sub_event'
		end
	end

	def destroy
		@event = Event.find(params[:id])
		
		if !verify_event_not_in_use || !verify_event_owner
			redirect_to :action => 'index'
			return
		end

		if @event.feature_events.size > 0
			flash[:notice] = @event.name + ' is in use and cannot be deleted.'
		elsif @event.destroy
			flash[:notice] = @event.name + ' sucessfully destroyed.'
		else
			flash[:notice] = @event.name + ' could not be destroyed.'
		end

		redirect_to :action => 'index', :page => params[:page]
	end

	def arm_event
		@event = Event.find(params[:id])

		if !verify_event_not_in_use || !verify_event_owner
			redirect_to :action => 'index'
			return
		end

		if @event.update_attribute(:armed, true)
			flash[:notice] = @event.name + ' sucessfully armed.'
			
			#add it to the pref list
			if PrefList.add(session[:kingdom][:id],'events',@event.id)
				flash[:notice]+= '<br/>Added to preference list'
			else
				flash[:notice]+= '<br/>Could not be added to preference list'
			end
		else
			flash[:notice] = @event.name + ' could not be armed.'
		end

		redirect_to :action => 'index', :page => params[:page]
	end

	def pref_lists
		session[:pref_list_type] = :event
		
		redirect_to :controller => '/management/pref_list'
	end
	
	
protected
	def verify_valid_event_sub_params
		if @event.class == EventCreature
			if Creature.find(:first,:conditions => ['armed = true AND (public = true or kingdom_id = ? or player_id	= ?) AND id = ?', session[:kingdom][:id], session[:player][:id],params[:event][:thing_id]])
				return true
			else
				flash[:notice] = "You can't use that creature"
				return false
			end
		else
			return true
		end
	end

	def verify_event_owner
		#if someone tries to edit a creature not belonging to them
		if @event.player_id != session[:player][:id] && 
			 @event.kingdom_id != session[:kingdom][:id]
			flash[:notice] = 'An error occured while retrieving ' + @event.name
			false
		else
			true
		end
	end

	def verify_event_not_in_use
		if @event.armed
			flash[:notice] = @event.name + ' cannot be edited; it is already being used.'
			false
		else
			true
		end
	end

	def get_event_types
		#set up the event types king can edit
		if session[:player].admin 
			#only admins have access to certain things. Regular kings have a limited subset of things they can edit
			@event_types = [ ['creature', EventCreature ],
											 ['disease', EventDisease ],
											 ['item', EventItem ],
											 ['move', EventMoveLocal],
											 ['move', EventMoveRelative],
											 ['quest', EventQuest],
											 ['stat', EventStat] ]
		else
			@event_types = [ ['creature', EventCreature ],
											 ['item', EventItem ],
											 ['move', EventMoveLocal],
											 ['move', EventMoveRelative],
											 ['quest', EventQuest] ]
		end
	end
	
	def calc_sub_event_cost
		#Populate the sub_event and whatever variables that particular sub event needs for its form.
		if @event.event_type == SpecialCode.get_code('event_type','creature')
			#the more of a creature in existance, the cheaper it is to use
			@cost = @event_sub.creature.gold + (@event_sub.creature.experience / (@event_sub.creature.number_alive + 5))
			@cost = (@cost * @event_sub.high) - (@cost * (@event_sub.low - 1))
		elsif @event.event_type == SpecialCode.get_code('event_type','disease') &&
					@event_sub.cures?
			#diseases events only cost if tehy cure the disease
			d = @event_sub.disease
			@cost = Disease.abs_cost(d)
		elsif @event.event_type == SpecialCode.get_code('event_type','item') 
			@cost = @event_sub.item.price * @event_sub.number
		elsif @event.event_type == SpecialCode.get_code('event_type','move')
			@cost = 0
		elsif @event.event_type == SpecialCode.get_code('event_type','npc')
			@cost = 0
		elsif @event.event_type == SpecialCode.get_code('event_type','pc') 
			@cost = 0
		elsif @event.event_type == SpecialCode.get_code('event_type','quest')
			@cost = 0
		elsif @event.event_type == SpecialCode.get_code('event_type','stat')
			d = @event_sub
			@cost = d.stat.str.abs + d.stat.dex.abs + d.stat.con.abs + d.stat.dam.abs + d.stat.dfn.abs + d.stat.int.abs + d.stat.mag.abs + d.health.HP.abs + d.health.MP.abs
		else
			flash[:notice] = 'Invalid type! Quit trying to hack it!'
			@cost = 0
		end
	end
	
	def pop_sub_event
		#Populate the sub_event and whatever variables that particular sub event needs for its form.
		if @event.event_type == SpecialCode.get_code('event_type','creature')
			@list = session[:kingdom].creature_pref_list
			
			@creatures = []
			for l in @list
				@creatures << l.creature
			end
			#@event_sub = EventCreature.find_first(:event_id => @event.id)
			@event_sub = @event.event_creature
			if @event_sub.nil?
				@event_sub = EventCreature.new
			end
		elsif @event.event_type == SpecialCode.get_code('event_type','disease')
			@diseases = Disease.find(:all)

			#@event_sub = EventDisease.find_first(:event_id => @event.id)
			@event_sub = @event.event_disease
			if @event_sub.nil?
				@event_sub = EventDisease.new
			end
		elsif @event.event_type == SpecialCode.get_code('event_type','item') 
			@items = Item.find(:all)

			#@event_sub = EventItem.find_first(:event_id => @event.id)
			@event_sub = @event.event_item
			if @event_sub.nil?
				@event_sub = EventItem.new
			end
		elsif @event.event_type == SpecialCode.get_code('event_type','move')
			#@levels = Level.find_all(:kingdom_id => session[:kingdom][:id])
			@levels = session[:kingdom].levels
			@move_types = []
			@move_types << SpecialCode.get_code('move_type', 'local')
			@move_types << SpecialCode.get_code('move_type', 'local_relative')
 
			#@event_sub = EventMove.find_first(:event_id => @event.id)
			@event_sub = @event.event_move
			
			if @event_sub.nil?
				@event_sub = EventMove.new
			end
			if params[:local_relative]
				@event_sub.move_type = params[:local_relative]
			end
		elsif @event.event_type == SpecialCode.get_code('event_type','npc')
			#@npcs = Npc.find_all(:kingdom_id => session[:kingdom][:id])
			@npcs = session[:kingdom].npcs
		 
			#@event_sub = EventNpc.find_first(:event_id => @event.id)
			@event_sub = @event.event_npc
			if @event_sub.nil?
				@event_sub = EventNpc.new
			end
		elsif @event.event_type == SpecialCode.get_code('event_type','pc') 
			#@pcs = PlayerCharacter.find_all(:kingdom_id => session[:kingdom][:id])
			@pcs = session[:kingdom].player_characters
			
			#@event_sub = EventPlayerCharacter.find_first(:event_id => @event.id)
			@event_sub = @event.event_player_character
			if @event_sub.nil?
				@event_sub = EventPlayerCharacter.new
			end
		elsif @event.event_type == SpecialCode.get_code('event_type','quest')
			#@event_sub = EventQuest.find_first(:event_id => @event.id)
			@event_sub = @event.event_quest
			if @event_sub.nil?
				@event_sub = EventQuest.new
			end
		elsif @event.event_type == SpecialCode.get_code('event_type','stat')
			#@event_sub = EventStat.find_first(:event_id => @event.id)
			@event_sub = @event.event_stat
			if @event_sub.nil?
				@event_sub = EventStat.new
				@stat = StatEventStat.new(params[:stat])
				@health = HealthEventStat.new(params[:health])
			else
				@stat = @event_sub.stat
				@health = @event_sub.health
			end
		else
			flash[:notice] = 'Invalid type! Quit trying to hack it!'
		end
	end
end
