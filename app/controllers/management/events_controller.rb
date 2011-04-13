class Management::EventsController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update, :arm_event ], :redirect_to => { :action => :index }


	#**********************************************************************
	#EVENT MANAGEMENT
	#**********************************************************************
	def index
		@events = Event.get_page(params[:page], session[:player][:id], session[:kingdom][:id])
	end

	def show
		@event = Event.find(params[:id])
	end

	def new
		@event = Event.new_of_kind(params[:event])
		@event_types = Event.get_event_types(session[:player].admin )
		@event_rep_types = SPEC_CODET['event_rep_type'].to_a
		
		pop_sub_event
	end

	def create
		new
		
		@event.player_id = session[:player][:id]
		@event.kingdom_id = session[:kingdom][:id]
		if @event.kind == "EventCreature" || @event.kind == "EventStat"
			@event.flex = params[:flex][0].to_s + ";" + params[:flex][0].to_s
		end
		
		@event.cost = 500

		if good_event_params & @event.save
			@extras=true
			if @stat || @health
				@stat.update_attributes(params[:stat].merge(:owner_id => @event.id)) &
					@health.update_attributes(params[:health].merge(:owner_id => @event.id)) || @extras = false
			end
			@event.reload #to refrsh the .stat and .health stuff
			if @extras
				@event.update_attribute(:cost, 500 + @event.total_cost)
				flash[:notice] = @event.name + ' was successfully created.'
				redirect_to :action => 'index'
				return
			end
		end
		render :action => 'new'
	end

	def edit
		@event = Event.find(params[:id])
		@event_rep_types = SPEC_CODET['event_rep_type'].to_a
		pop_sub_event
	end

	def update
		edit
		
		if @event.kind == "EventCreature" || @event.kind == "EventStat"
			@flex = params[:flex][0].to_s + ";" + params[:flex][0].to_s
		end
		
		if is_event_not_in_use & is_event_owner & good_event_params &
				@event.update_attributes(params[:event].merge(:flex => @flex))
			@extras=true
			if @stat || @health
				@stat.update_attributes(params[:stat].merge(:owner_id => @event.id)) & 
					@health.update_attributes(params[:health].merge(:owner_id => @event.id)) || @extras = false
			end
			
			if @extras
				@event.update_attribute(:cost, 500 + @event.total_cost)
				flash[:notice] = @event.name + ' was successfully updated.'
				redirect_to :action => 'index'
				return
			end
		end
		render :action => 'edit'
	end

	def destroy
		@event = Event.find(params[:id])
		
		if !is_event_not_in_use || !is_event_owner
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

		if !is_event_not_in_use || !is_event_owner
			redirect_to :action => 'index'
			return
		end

		if @event.update_attribute(:armed, true)
			flash[:notice] = @event.name + ' sucessfully armed.'
			
			#add it to the pref list
			if PrefListEvent.add(session[:kingdom][:id],@event.id)
				session[:kingdom].pref_list_events.reload
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
		session[:pref_list_type] = PrefListEvent
		
		redirect_to :controller => '/management/pref_list'
	end
	
	
protected
	def good_event_params
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

	def is_event_owner
		#if someone tries to edit a creature not belonging to them
		if @event.player_id != session[:player][:id] && 
			 @event.kingdom_id != session[:kingdom][:id]
			flash[:notice] = 'An error occured while retrieving ' + @event.name
			false
		else
			true
		end
	end

	def is_event_not_in_use
		if @event.armed
			flash[:notice] = @event.name + ' cannot be edited; it is already being used.'
			false
		else
			true
		end
	end
	
	def pop_sub_event
		#Populate the sub_event and whatever variables that particular sub event needs for its form.
		@kingdom = session[:kingdom]
		case @event.kind
			when "EventCreature"
				@creatures = @kingdom.pref_list_creatures.reload.collect{|plc| plc.creature}
			when "EventDisease"
				@diseases = Disease.find(:all)
			when "EventItem"
				@items = Item.find(:all)
			when "EventMoveLocal"
				@levels = @kingdom.levels
			when "EventNpc"
				@npcs = @kingdom.npcs
			when "EventPlayerCharacter"
				@pcs = @kingdom.player_characters
			when "EventStat"
				@stat = @event.stat || StatEventStat.new(params[:stat])
				@health = @event.health || HealthEventStat.new(params[:health])
			when "EventQuest"
				@quests = @kingdom.active_quests.reload
		end
	end
end
