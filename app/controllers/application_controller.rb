# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time
	protect_from_forgery # See ActionController::RequestForgeryProtection for details

	# Scrub sensitive parameters from your log
	# filter_parameter_logging :password
	
		
	before_filter :system_up
	
	def system_up
		if SystemStatus.status(1) != 1
			print "halt!"
			render :file => "#{RAILS_ROOT}/public/9001.html"
			return false
		end
	end
	
	def authenticate
		if session[:player].nil? ||
				(Player.find(:first, :conditions => ["handle = ?", session[:player][:handle]]).passwd != session[:player][:passwd])
			redirect_to :controller => '/account', :action => 'verify'
			return false
		else
			#set the kingbit so player can manage their kingdoms if tehy are king
			
			is_king
			return true
		end
	end

	#the admin filter
	def is_admin
		if session[:player].nil?
			redirect_to :controller => '/account', :action => 'verify'
		else
			if session[:player].admin
				return true
			else
				redirect_to :controller => '/home'
				return false
			end
		end
	end
	
	#Checks that the player is a king
	def is_king
		@pcs = PlayerCharacter.find(:all, :conditions => ['player_id = ?', session[:player][:id]])
		for pc in @pcs
			if Kingdom.find(:first, :conditions => ['player_character_id = ?', pc.id])
				session[:kingbit] = true
				return true
			end
		 end
		return false
	end
	
	def king_filter
		if !is_king
			redirect_to :controller => 'game', :action => 'main'
			return false
		else
			return true
		end
	end
	
	#check that the player character selected is the king of the selected kingdom
	def char_is_king
		if session[:player].nil?
			redirect_to :controller => 'account', :action => 'verify'
			return false
		elsif session[:player_character].kingdoms.size == 0
			print "NOT A KING\n"
			redirect_to :controller => 'game', :action => 'main'
			return false
		elsif session[:player_character].nil? || session[:kingdom].nil?
			redirect_to :controller => 'management'
			return false
		elsif session[:player_character].id != session[:kingdom][:player_character_id]
			flash[:notice] = 'Must have the king of the kingdom selected at your current character to do that.'
			redirect_to :controller => '/management' 
			return false
		else
			return true
		end
	end
		
	#Its ok to make all this stuff protected right?
protected
	def debuggery(crap)
		print "\n" + crap.to_s
	end

	#******************************************************************************************
	#HELPER ROUTINES FOR THE QUEST MANAGEMENT CONTROLLERS
	#MAINLY IMAGES AND INITIALIZING OF VARIABLES
	#******************************************************************************************
	def handle_creature_image
		if @creature[:image_id].nil?
			@image_type = SpecialCode.get_code('image_type','creature')
			#@new_thing = 'new_creature'
			handle_image(@creature,0,0)
		else
			flash[:notice] = 'An image was selected from the dropdown.<br/>'
		end
	end
		
	def handle_feature_image
		if @feature[:image_id].nil?
			@image_type = SpecialCode.get_code('image_type','kingdom')
			#@new_thing = 'new_feature'
			handle_image(@feature,10,15)
		else
			flash[:notice] = 'An image was selected from the dropdown.<br/>'
		end
	end

	def handle_image(thing,row,col)
	p params[:image].inspect
		if params[:image][:image_text] != ""
			@image = Image.new
			resize_image(row,col)
			@image.image_text = params[:image][:image_text]
			@image.player_id = session[:player][:id]
			@image.kingdom_id = session[:kingdom][:id]
			@image.public = false
			@image.image_type = @image_type
			@image.name = thing.name + ' image'
			if !@image.save
				flash[:notice] = 'Could not create image.<br />'
				#render :action => @new_thing
				render :action => 'new'
			else
				flash[:notice] = 'Made new image.<br />'
				thing.image_id = @image.id
				@images << @image
			end
		end
	end

	def resize_image(row,col)
		if row == 0 && col == 0
			return
		end
		#because IE sucks and adds the \r character to the text area lines, possibly due to 
		#the text area beinga hard stop
		@foo = params[:image][:image_text].gsub(/\r/,"")
		
		@foo = @foo.split("\n")
		
		@bim = ""
		
		if @foo.size < row
			while @foo.size < row
				@foo << " " * col
			end
		elsif @foo.size > row
			@foo = @foo[0..(row-1)]
		end
		
		for fo in @foo
			if @bim.length > 0
				@bim += "\n"
			end
			if fo.length < col
				fo += " " * (col - fo.length)
			else
				fo = fo[0..(col-1)]
			end
			@bim += fo
		end

		params[:image][:image_text] = @bim
	end
	
	def update_creature_image
		if !@creature[:image_id].nil? && params[:image][:image_text] != ""
			#@edit_thing = 'edit_creature'
			@image_type = SpecialCode.get_code('image_type','creature')
			update_image(@creature,0,0)
			params[:creature][:image_id] = @creature.image_id
		else
			flash[:notice] = 'An image was selected from the dropdown.<br/>'
		end
	end
 
	def update_feature_image
		if !@feature[:image_id].nil? && params[:image][:image_text] != ""
			#@edit_thing = 'edit_feature'
			@image_type = SpecialCode.get_code('image_type','kingdom')
			update_image(@feature,10,15)
			params[:feature][:image_id] = @feature.image_id
		else
			flash[:notice] = 'An image was selected from the dropdown.<br/>'
		end
	end

	def update_image(thing,row,col)
		@image = Image.find(:first, :conditions => ['name = ?', thing.name + ' image'])
		if @image.nil?
			handle_image(thing,row,col)
		else
			resize_image(row,col)
			@image.image_text = params[:image][:image_text]
			if !@image.save
				flash[:notice] = 'Could not update image.<br />'
				render :action => @edit_thing
			else
				thing.image_id = @image.id
				flash[:notice] = 'Updated image.<br />'
			end
		end
	end

	def handle_creature_init_vars
		@crit = SpecialCode.get_code('image_type', 'creature')	
		handle_init_vars
	end
	
	def handle_feature_init_vars
		@crit = SpecialCode.get_code('image_type', 'kingdom')
		handle_init_vars
	end
	
	#only available to teh administrators, for building the outer world
	def handle_world_feature_init_vars
		@crit = SpecialCode.get_code('image_type', 'world')
		handle_init_vars	
	end
	
	def handle_init_vars
		@kingdom_id = session[:kingdom][:id]
		@player_id = session[:player][:id]
		#@images = Image.find_all(:player_id => @player_id, :image_type => @crit)
		#@images << Image.find_all(:kingdom_id => @kingdom_id, :image_type => @crit)
		#@images.flatten!.uniq!
		@images = Image.find_by_sql(['select * from images where (public = true or player_id = ? or kingdom_id = ?) and image_type = ? order by name',@player_id,@kingdom_id,@crit])
	end
	
	#Delete the event for an NPC that is either fired or is killed
	def destroy_npc_event(npc)
		#delete that event
		@event_npc = npc.event_npcs.last
		@event = @event_npc.event
		@feature_event = @event.feature_events.last #dunno if this would be the rigth oen. have to test.
		
		@event_npc.destroy
		@feature_event.destroy
		#@event.destroy		#This cannot be destroyed, there might be a linked done event.
	end
	
	def create_peasant_feature_event(feature)
		#MAKE EVENT	
		@event = Event.new
		@event.kingdom_id = -1
		@event.player_id = -1
		@event.event_rep_type = SpecialCode.get_code('event_rep_type','unlimited')
		@event.name = "\nSYSTEM GENERATED"		 #name to anounce this event was generated by the system
		@event.event_type = SpecialCode.get_code('event_type','creature')
		@event.armed = true
		@event.cost = 0
		
		if @event.save
			flash[:notice] = "Created event\n"
		else
			#break code in case event fails to save while developeing this stuff
			flash[:n][:n]
		end
	
		#MAKE SUB EVENT
		@event_creature = EventCreature.new
		@event_creature.event_id = @event.id
		@event_creature.creature_id = Creature.find(:first, :conditions => ['name = ?', "Peasant"]).id
		@event_creature.low = 1
		@event_creature.high = feature.num_occupants
		
		if @event_creature.save
			flash[:notice] += "Created event_npc\n"
		else
			#break code in case event fails to save while developing this stuff
			flash[:n][:n]
		end

		@feature_event = FeatureEvent.new
		
		@feature_event.feature_id = feature.id
		@feature_event.event_id = @event.id
		@feature_event.chance = 65.0
		@feature_event.priority = 42
		@feature_event.choice = true
		
		@feature_event.save
	end
	
	def minimum(x,y)
		y > x ? x : y
	end
	
	def maximum(x,y)
		x > y ? x : y
	end
	
	def gain_xp(who,xp)
		if who.class != Creature #Creatures dont gain XP
		who.transaction do
			who.lock!
				who.experience += xp
		who.save!
			end
		end
	end
end
