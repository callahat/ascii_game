class Management::FeaturesController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update, :create_feature_event, :update_feature_event, :destroy_feature_event, :arm_feature ],				 :redirect_to => { :action => :index }
	
	
	#**********************************************************************
	#FEATURE MANAGEMENT
	#**********************************************************************
	public
	def index
		#design features
		#@features = Feature.find_by_sql(['select * from features where player_id = ? or kingdom_id = ? order by armed,world_feature,name',session[:player][:id],session[:kingdom][:id]])
		@features = Feature.get_page(params[:page], session[:player][:id], session[:kingdom][:id])
	end

	def show
		@feature = Feature.find(params[:id])
		@feature_events = @feature.feature_events
	end
	
	def new
		@feature = Feature.new
		handle_feature_init_vars
	end
	
	def create
		@feature = Feature.new(params[:feature])
		handle_feature_init_vars
		calc_feature_cost
		@feature.cost = @cost
		
		handle_feature_image
		
		if @feature.save
			flash[:notice] = @feature.name + ' was sucessfully created.'
			redirect_to :action => 'index'
		else
			flash[:notice] = @feature.name + ' was not created.'
			render :action => 'new'
		end
	end
	
	def edit
		@feature = Feature.find(params[:id])
		@image = @feature.image
		handle_feature_init_vars
	end
	
	def update
		@feature = Feature.find(params[:id])
		@image = @feature.image
		handle_feature_init_vars
		if !verify_feature_owner || !verify_feature_not_in_use
			redirect_to :action => 'index'
			return
		end
		update_feature_image
		
		if @feature.update_attributes(params[:feature])
			calc_feature_cost
			@feature.cost = @cost
			@feature.save
			flash[:notice] = @feature.name + ' sucessfully updated.'
			redirect_to :action => 'show', :id => params[:id]
		else
			flash[:notice] = @feature.name + ' failed to updated.'
			render :action => 'edit'
		end
	end
	
	def new_feature_event
		@feature_event = FeatureEvent.new
		@feature_event.feature_id = params[:id]
		setup_events_array
	end
	
	def create_feature_event
		@feature_event = FeatureEvent.new(params[:feature_event])
		@feature = Feature.find(params[:id])
		setup_events_array
		
		if !verify_valid_event || !verify_feature_owner
			redirect_to :action => 'new_feature_event', :id => params[:id]
			return
		end
		
		if @feature_event.save
			flash[:notice] = 'Feature event created.'
			update_feature_cost
		else
			flash[:notice] = 'Feature event failed to be created.'
			render :action => 'new_feature_event'
		end
	end
	
	def edit_feature_event
		@feature_event = FeatureEvent.find(params[:id])
		setup_events_array
	end
	
	def update_feature_event
		@feature_event = FeatureEvent.find(params[:id])
		@feature = Feature.find(@feature_event.feature_id)
		
		if !verify_feature_owner || !verify_feature_not_in_use
			redirect_to :action => 'index'
			return
		end
		if !verify_valid_event
			redirect_to :action => 'edit_feature_event', :id => @feature.id
			return
		end
		
		setup_events_array
		if @feature_event.update_attributes(params[:feature_event])
			flash[:notice] = 'Feature event updated.'
			update_feature_cost
		else
			flash[:notice] = 'Feature event failed to update.'
			render :action => 'edit_feature_event'
		end
	end
	
	def destroy_feature_event
		@feature_event = FeatureEvent.find(params[:id])
		@feature = Feature.find(@feature_event.feature_id)
		
		if !verify_feature_owner || !verify_feature_not_in_use
			redirect_to :action => 'index'
			return
		end
		
		if @feature_event.destroy
			flash[:notice] = 'Feature event destroyed.'

			#update feature cost
			@feature = @feature_event.feature
			calc_feature_cost
			@feature.cost = @cost
			if @feature.save
				flash[:notice] += '<br />Feature cost updated.'
			else
				flash[:notice] += '<br />Feature cost failed to update.'
			end
			redirect_to :action => 'show', :id => @feature.id
		else
			flash[:notice] = 'Could not destroy feature event.'
			redirect_to :action => 'show', :id => @feature.id
		end
	end
	
	def arm_feature
		@feature = Feature.find(params[:id])
		if !verify_feature_owner
			redirect_to :action => 'index'
			return
		end

		#create the peasant feature encounters if applicable
		#must have the peasant creature and event in the database or this will fail
		flash[:notice] = ''
		@peasant = Creature.find(:first, :conditions => ['name = ?', 'Peasant'])
		if @peasant.nil?
			flash[:notice] += 'The Peasants haven\'t been created yet!<br/>'
		elsif !@feature.num_occupants.nil? && @feature.num_occupants > 0
			if !create_peasant_feature_event(@feature)
				flash[:notice] = 'Failed to make the peasant feature event.'
			end
		end
		
		if @feature.update_attribute(:armed, true)
			flash[:notice] += @feature.name + ' sucessfully armed.'
			#add it to the pref list
			if !@feature.world_feature
				if PrefList.add(session[:kingdom][:id],'features',@feature.id)
					flash[:notice]+= '<br/>Added to preference list'
				else
					flash[:notice]+= '<br/>Could not be added to preference list'
				end
			end
		else
			flash[:notice] += @feature.name + ' could not be armed.'
		end

		redirect_to :action => 'index', :page => params[:page]
	end
	
	def destroy
		@feature = Feature.find(params[:id])
		if !verify_feature_owner || !verify_feature_not_in_use
			redirect_to :action => 'index'
			return
		end
		
		for feature_event in @feature.feature_events
			feature_event.destroy
		end
		
		if @feature.destroy
			flash[:notice] = 'Feature destroyed.'
		else
			flash[:notice] = 'Feature was not destroyed.'
		end
		redirect_to :action => 'index', :page => params[:page]
	end
	
	def pref_lists
		session[:pref_list_type] = :feature
		
		redirect_to :controller => '/management/pref_list'
	end
	
	
	
protected
	def verify_valid_event
		print "\n" + params[:feature_event][:event_id]
	
		if Event.find(:first,:conditions => ['armed = true AND (kingdom_id = ? or player_id	= ?) AND id = ?', session[:kingdom][:id], session[:player][:id], params[:feature_event][:event_id]])
			return true
		else
			flash[:notice] = "You can't use that event"
			return false
		end
	end


	def calc_feature_cost
		if @feature.num_occupants.nil?
			@feature.num_occupants = 0
		end
		if @feature.store_front_size.nil?
			@feature.store_front_size = 0
		end
	
		#can be expensive computatinally.
		@fees = @feature.feature_events
		@cost = 500	#base cost of any feature
		
		if @feature.store_front_size > 0
			@cost += ((@feature.store_front_size).power!(@feature.store_front_size)) * 10
		end
			
		if @fees.nil? || @fees.size == 0
			@cost += @feature.num_occupants * 100
		else
			@cost += @feature.num_occupants * 500
			@L1 = SpecialCode.get_code('event_rep_type','limited')
			@L2 = SpecialCode.get_code('event_rep_type','limited_per_char')
			
			for fee in @fees
				if fee.event.event_rep_type == @L1
					@cost += fee.event.cost * (fee.chance / 100.0)
				elsif fee.event.event_rep_type == @L2
					@cost += fee.event.cost * (fee.chance / 50.0)
				else
					@cost += fee.event.cost
				end
			end
		end
	end

	def update_feature_cost
		#update feature cost
		@feature = @feature_event.feature
		calc_feature_cost
		@feature.cost = @cost
		if @feature.save
			flash[:notice] += '<br />Feature cost updated.'
			redirect_to :action => 'show', :id => @feature.id
		else
			flash[:notice] += '<br />Feature cost failed to update.'
			render :action => 'new_feature_event'	
		end
	end
	
	def verify_feature_owner
		#if someone tries to edit a feature not belonging to them
		if @feature.player_id != session[:player][:id] && 
			 @feature.kingdom_id != session[:kingdom][:id]
			flash[:notice] = 'An error occured while retrieving ' + @feature.name
			false
		else
			true
		end
	end

	def verify_feature_not_in_use
		if @feature.armed
			flash[:notice] = @feature.name + ' cannot be edited; it is already being used.'
			false
		else
			true
		end
	end
	
	def setup_events_array
		#@events = Event.find_by_sql(['select * from events where armed = true AND (player_id = ? or kingdom_id = ?) order by name',session[:player][:id],session[:kingdom][:id]])
		@list = session[:kingdom].event_pref_list
		
		@events = []
		
		for l in @list
			@events << l.event
		end
	end
end
