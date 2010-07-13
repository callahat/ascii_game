class Management::LevelsController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	def index
		@levels = Level.get_page(params[:page], session[:kingdom][:id])
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :index }

	def show
		@empty_image = Feature.find(:first, :conditions => ['kingdom_id = ? and player_id = ? and name = ?', -1, -1, "\nEmpty"]).image.image_text
		@level = Level.find(params[:id])
		@y,@x = 0,0
		verify_level_owner
		#@forlopworkaround = Array.new(@level.maxy,Array.new(@level.maxx))
	end

	def new
		@level = Level.new
		
		@lowest = session[:kingdom].levels.first.level - 1
		@highest = session[:kingdom].levels.last.level + 1
	end
	
	def create
		@level = Level.new(params[:level])
		
		#make sure king can afford
		@cost = (@level.level.abs.power! 3) * @level.maxx.to_i * @level.maxy.to_i
		session[:kingdom][:gold] = Kingdom.find(session[:kingdom][:id]).gold
		
		if @cost > session[:kingdom][:gold]
			flash[:notice] = 'It would cost ' + @cost.to_s + ' gold, which the kingdom doesn\'t have.'
			redirect_to :action => 'new'
		else
			session[:kingdom][:gold] -= @cost
			session[:kingdom].save
			@level.kingdom_id = session[:kingdom][:id]
			if @level.save
				@emtpy_feature = Feature.find(:first, :conditions => ['name = ? and kingdom_id = ? and player_id = ?', "\nEmpty", -1, -1])
				LevelMap.gen_level_map_squares(@level, @emtpy_feature)
				flash[:notice] = 'Level ' + @level.level.to_s + ' was successfully created.'
				flash[:notice] += '<br/>' + @savecount.to_s + ' map squares out of ' + (@level.maxy * @level.maxx).to_s + ' created.'
				redirect_to :action => 'index'
			else
				@lowest = session[:kingdom].levels.first.level - 1
				@highest = session[:kingdom].levels.last.level + 1
				render :action => 'new'
			end
		end
	end
	
	def edit
		#here goes code to edit the level map.
		@level = Level.find(params[:id])
		if !verify_level_owner
			redirect_to :action => 'levels'
			return
		end
		
		@gold = Kingdom.find(session[:kingdom][:id]).gold

		#@features = session[:kingdom].features
		setup_features_array
	end
	
	
	def update
		@level = Level.find(params[:id])
		if !verify_level_owner
			redirect_to :action => 'levels'
			return
		end
		
		#@features = session[:kingdom].features
		setup_features_array
		session[:kingdom][:gold] = Kingdom.find(session[:kingdom][:id]).gold
		
		calc_cost
		
		if @cost > session[:kingdom][:gold]
			flash[:notice] = 'There is not enough gold in your coffers to pay for the construction.<br/>'
			flash[:notice] += 'Available amount : ' + session[:kingdom][:gold].to_s + ' ; Total build cost : ' + @cost.to_s
			redirect_to :action => 'edit', :id => params[:id]
		elsif params[:map]
			session[:kingdom][:gold] -= @cost
			session[:kingdom].save
			
			@x,@y = 0,0
			
			while @y < @level.maxy
				while @x < @level.maxx
					@temp = @level.level_maps.find(:all, :conditions => ['ypos = ? and xpos = ?', @y, @x]).last
					#print "\n#{@temp.id}	#{@temp.nil?} #{@temp.feature_id} #{@temp.feature_id.to_i != params[:map][@y.to_s][@x.to_s].to_i} #{params[:map][@y.to_s][@x.to_s]}\n"
				
					#Destroy the level map if it has changed, and make a new one. 
					#Might want to timestamp this later.
					#but for now, just return the array of those level_maps, and get the last,
					#which should be the latest edit to the contents of that square.
					if (@temp.feature_id.to_i != params[:map][@y.to_s][@x.to_s].to_i) &&
						 (@temp.feature.nil? || @temp.feature.name[0..0] != "\n" || @temp.feature.name == "\nEmpty") &&
						 Feature.find(:first, :conditions => ['world_feature = false AND (kingdom_id = ? OR public = true) and id = ?', session[:kingdom][:id], params[:map][@y.to_s][@x.to_s].to_i])
						#if this is has storefronts, get rid of the previous store vacancies.
						if @temp.feature
							if @temp.feature.store_front_size.to_i > 0
								@stores = @temp.kingdom_empty_shops
								for store in @stores do
									store.destroy
								end
								#Also, get rid of any merchants that set up shop there.
								@fes = @temp.feature.feature_events
								for fe in @fes
									if fe.event.event_type == SpecialCode.get_code('event_type','npc')
										@npc = fe.event.event_npcs.last.npc
										destroy_npc_event(@npc)	#prevents a timewarp from letting players buy stuff back in time...
										@npc.is_hired = false
										@npc.save
									end
								end
							end
							if @temp.feature.num_occupants.to_i > 0
								Kingdom.transaction do
									session[:kingdom].lock!
									session[:kingdom].housing_cap -= @temp.feature.num_occupants
									session[:kingdom].save!
								end
							end
						end
					
						@temp = LevelMap.new
						@temp.level_id = @level.id
						@temp.xpos = @x
						@temp.ypos = @y
						@temp.feature_id = params[:map][@y.to_s][@x.to_s]
						@temp.save
						
						#Create new kingdom empty shops if necessary
						if !@temp.feature.nil?
							if @temp.feature.store_front_size.to_i > 0
								@size = @temp.feature.store_front_size.to_i
								@count = 0
								while @count < @size
									@vacant = KingdomEmptyShop.new
									@vacant.kingdom_id = session[:kingdom][:id]
									@vacant.level_map_id = @temp.id
									if !@vacant.save
										print "\nERROR: Failed to create kingdom empty shop!"+ Time.now
									end
									@count += 1
								end
							end
							if @temp.feature.num_occupants.to_i > 0
					Kingdom.transaction do
					session[:kingdom].lock!
									session[:kingdom].housing_cap += @temp.feature.num_occupants
					session[:kingdom].save!
								end
							end
						end
						#end create new empty shops
					end
					@x += 1
				end
				@x = 0
				@y += 1
			end
			flash[:notice] = 'Level was successfully updated. Cost was : ' + @cost.to_s
			redirect_to :action => 'show', :id => @level
		else
			redirect_to :action => 'show', :id => @level
		end
	end

	#Not only is this not good, the way the code is right now, it would leave all those
	#level_maps just dangling out	there with no parent level. BAD.
	#
	#def destroy
	#	@level = Level.find(params[:id])
	#	if !verify_level_owner
	#		redirect_to :action => 'levels'
	#		return
	#	end
	#	
	#	@level.destroy
	#	redirect_to :action => 'index'
	#end
	
protected
	def calc_cost
		@cost = 0
		@x,@y = 0,0
		
		if params.nil? || params[:map].nil? #this level has nothing that can be edited.
			return
		end
	
		while @y < @level.maxy
			while @x < @level.maxx
				@old = @level.level_maps.find(:all, :conditions => ['ypos = ? and xpos = ?', @y, @x]).last.feature
				if !params[:map][@y.to_s][@x.to_s].nil? && params[:map][@y.to_s][@x.to_s] != ""
					@new = Feature.find(params[:map][@y.to_s][@x.to_s])
				else
					@new = nil
				end
				
				if @old != @new
					if @old == nil || @old == ""
						@old = 0
					else
						@old = @old.cost
					end
					if @new == nil || @new == ""
						@new = 0
					else
						@new = @new.cost
					end
					#print "#{@new} - #{@old} = #{params[:map][@y.to_s][@x.to_s]}\n"
					@cost += @new - (@old / 5)
				end
				@x += 1
			end
			@x = 0
			@y += 1
		end
	end

	def verify_level_owner
		#if someone tries to edit a level map not belonging to the kingdom
		if @level.kingdom_id != session[:kingdom][:id]
			flash[:notice] = 'An error occured while retrieving level ' + @level.level
			false
		else
			true
		end
	end

	#this'll need to be updated to use the preference list
	def setup_features_array
		##make the list of features
		#@lfeatures = Feature.find(:all, :conditions => ['world_feature = false AND armed = true AND (kingdom_id = ? OR public = true)', session[:kingdom][:id]], :order => 'name')
		@lfeatures = session[:kingdom].pref_list_features

		@features = []
		@lfeatures.each do |f| 
			feature = f.feature
			feature.name = feature.name[0..11]
			if feature.name[12..12] != nil
				feature.name = feature.name + "..."
			end
			@features << feature
		end
	end
end
