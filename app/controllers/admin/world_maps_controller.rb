class Admin::WorldMapsController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin
	
	layout 'admin'

	def index
		session[:wid] = nil	#reset the selected world
		@worlds = WorldMap.get_page(params[:page])
	end

#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :index }

	def show
		if session[:wid].nil?
			session[:wid] = params[:wid] #save it, forget it later
		end
	
		#clear out the map that's being looked at
		session[:bigxpos] = nil
		session[:bigypos] = nil
		
		@world = World.find(session[:wid])
		@x,@y = @world.minbigx,@world.minbigy
	end

	def show_map
		if !params[:bigxpos].nil? || !params[:bigypos].nil?
			session[:bigxpos] = params[:bigxpos]
			session[:bigypos] = params[:bigypos]
		end
		
		@world = World.find(session[:wid])
		@x,@y = 1,1
	end

	def new
		#clear out the map that's being looked at
		session[:bigxpos] = nil
		session[:bigypos] = nil
		
		@world = World.find(session[:wid])
		@x,@y = @world.minbigx, @world.minbigy
	end

	def create
		@coords = params[:map][:loc]
		@bigx = @coords[0..@coords.index(',')]
		@bigy = @coords[(@coords.index(',')+1)..-1]
		
		print "\n"
		print @bigx
		print "\n"
		print @bigy
		print "\n"
		print "." + @coords + "."
		print "\n"
		
		#generate the empty squares for the submap
		gen_world_map_squares
		flash[:notice] = 'Generated squares for ' + @bigx + ' by ' + @bigy
		redirect_to :action => 'show'
	end
	
	
	def edit
		#here goes code to edit the level map.
		setup_features_array
		
		@world = World.find(session[:wid])
	end
	
	
	def update
		@world = World.find(session[:wid])
				
		setup_features_array
			
		@x,@y = 1,1

		while @y <= @world.maxy
			while @x <= @world.maxx
				@temp = @world.world_maps.find(:all, :conditions => ['bigypos = ? and bigxpos = ? and ypos = ? and xpos = ?', session[:bigypos], session[:bigxpos], @y, @x]).last
				#print "\n#{@temp.id}	#{@temp.nil?} #{@temp.feature_id} #{@temp.feature_id.to_i != params[:map][@y.to_s][@x.to_s].to_i} #{params[:map][@y.to_s][@x.to_s]}\n"
				
				#Destroy the level map if it has changed, and make a new one. 
				#Might want to timestamp this later.
				#but for now, just return the array of those level_maps, and get the last,
				#which should be the latest edit to the contents of that square.
				if @temp.feature_id.to_i != params[:map][@y.to_s][@x.to_s].to_i &&
					 (@temp.feature.nil? || @temp.feature.name[0..0] != "\n")
					@temp = WorldMap.new
					@temp.world_id = @world.id
					@temp.xpos = @x
					@temp.ypos = @y
					@temp.bigxpos = session[:bigxpos]
					@temp.bigypos = session[:bigypos]
					
					@temp.feature_id = params[:map][@y.to_s][@x.to_s]
					@temp.save

				end
				@x += 1
			end
			@x = 1
			@y += 1
		end
			
		flash[:notice] = 'Section of the world was successfully updated.'
		redirect_to :action => 'show_map'
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
	def gen_world_map_squares
		#now, create the level map squares
		@world = World.find(session[:wid])
		@x, @y, @savecount = 1, 1, 0
		
		while @y <= @world.maxy
			while @x <= @world.maxx
				@temp = WorldMap.new
				@temp.world_id = @world.id
				@temp.xpos = @x
				@temp.ypos = @y
				@temp.bigxpos = @bigx
				@temp.bigypos = @bigy
				@temp.feature_id = nil
				
				@temp.save

				@x += 1
			end
			@x = 1
			@y += 1
		end
	end
	
	def setup_features_array
		##make the list of features, for the world, just going to sink the non prefs to end of the array
		@allf = Feature.find(:all, :conditions => ['world_feature and armed'])
		@lpref = Kingdom.find(-1).feature_pref_list

		@findex = []
		@features = []
		@lpref.each do |lpref|
			f = lpref.feature
			f.name = f.name[0..11]
			if f.name[12..12] != nil
				f.name = f.name + "..."
			end
			@features << f
			@findex << f.id
		end
		
		
		@allf.each do |f|
			if @findex.index(f.id).nil?
				f.name = f.name[0..11]
				if f.name[12..12] != nil
					f.name = f.name + "..."
				end
				@features << f
			end
		end
		
	end
end
