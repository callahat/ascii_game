class Game::GeneralController < ApplicationController
	before_filter :authenticate
	before_filter :pc_alive
	
	layout 'main'

		# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_heal, :do_choose, :do_train ],				 :redirect_to => { :action => :feature }
	
	
	#General controller, for events that the player must be alive to complete.
	
	def disease
			@event = session[:current_event]
			@event_disease = @event.event_disease
			@disease = @event_disease.disease
		
		stat_change_dir = 0
		
			if @event_disease.cures? 
			print "\nTrying to cure player id: " + session[:player_character].id.to_s + " of disease id: " + @disease.id.to_s
			if session[:player_character].illnesses.exists?(:disease_id => @disease.id)
				stat_change_dir = 1
				session[:player_character].illnesses.find(:first, :conditions => ['disease_id = ?', @disease.id]).destroy
					@message = 'Your case of ' + @disease.name + ' has cleared up!'
				else
					#no point in going on, player already healthy, nothing happens.
					@message = '...Nothing interesting happened.'
				end
		elsif !session[:player_character].illnesses.exists?(:disease_id => @disease.id)
			stat_change_dir = -1
			if Illness.infect(session[:player_character], @disease)
					@message = 'You don\'t feel so good...'
				else
					@message = 'uh oh, you should\'ve gotten a disease from that!'
				end
			else
				#don't infect someone with the same organism more than once
				@message = "This place feels unhealthy"
			end
		
		if stat_change_dir != 0
			@stat = session[:player_character].stat.dup
			PlayerCharacter.transaction do
				@stat.lock!
				if stat_change_dir > 0
					@stat.add_stats(@disease.stat)
				else
					@stat.subtract_stats(@disease.stat)
		end
				@stat.save!
			end
		end
		
		session[:completed] = true
		render :action => '../complete'
	end
	
	def item
		@event_item = session[:current_event].event_item
		@item = @event_item.item
		
		print "\nITEM:" + @item.id.to_s
		
		if PlayerCharacterItem.update_inventory(session[:player_character].id,@item.id,@event_item.number)
			flash[:notice] = 'Found ' + @event_item.number.to_s + ' ' + @item.name
		else
			flash[:notice] = 'Failed to update the inventory'
		end
		
		session[:completed] = true
		render :action => '../complete'
	end
	
	def quest
		#why do i even have this event type anymore? Isn't it just a textbox at this point?
		@message = session[:current_event].event_quest.text
		
		session[:completed] = true
		render :action => '../complete'
	end
	
	def stat
		@pc = session[:player_character].dup
			@event_stat = session[:current_event].event_stat
		
		PlayerCharacter.transaction do
			@pc.lock!
			@pc.gold += @event_stat.gold
			@pc.experience += @event_stat.experience
			@pc.save!
			end
		Health.transaction do
			@health = @pc.health.lock!
			@health.HP += @event_stat.HP
			@health.MP += @event_stat.MP
			if @health.HP <= 0
				@health.wellness = SpecialCode.get_code('wellness','dead')
			end
			@health.save!
		end
		StatPc.transaction do
			@stat = @pc.stat.lock!
			@stat.add_stats(@disease.stat)
			@stat.save!
		end
			@message = @event_stat.text
		
		session[:player_character] = @pc
		session[:completed] = true
		render :action => '../complete'
	end
	
	def spawn_kingdom
		#make sure player is really eligible to found a new kingdom. Should make foundking a kingdom always
		#part of a choice, and not have special logic that asks player if they would like to found a new one.
		if session[:current_event].event_type != SpecialCode.get_code('event_type','spawn_kingdom') ||
				!Kingdom.find(:first, :conditions => ['player_character_id = ?', session[:player_character].id]).nil? ||
				session[:player_character].level < 42
			session[:completed] = false
			session[:spawn_kingdom] = nil
			redirect_to :controller => '/game', :action => 'complete'
			return
		end
		
		@kingdom = Kingdom.new
		session[:spawn_kingdom] = true
	end
	
	def do_spawn
		if !session[:spawn_kingdom]
			session[:completed] = false
			redirect_to :controller => '/game', :action => 'complete'
			return
		end
		
	WorldMap.transaction do
			@world_map = session[:last_action]
		@world_map.lock!
			@emtpy_feature = Feature.find(:first, :conditions => ['name = ? and kingdom_id = ? and player_id = ?', "\nEmpty", -1, -1])
		
			if @world_map.id != WorldMap.find(:all, :conditions => ['bigypos = ? and bigxpos = ? and ypos = ? and xpos = ?', @world_map.bigypos, @world_map.bigxpos, @world_map.ypos, @world_map.xpos]).last.id
				flash[:notice] = "Someone has already founded a kingdom here!"
				@world_map.save!
				session[:spawn_kingdom] = false
				session[:completed] = false
				redirect_to :controller => '/game', :action => 'complete'
				return
			end
			#MAKE KINGDOM
			@kingdom = Kingdom.new(params[:kingdom])
			@kingdom.player_character_id = session[:player_character][:id]
			@kingdom.num_peasants = rand(400) + 100
			@kingdom.gold = 55000
			@kingdom.tax_rate = 5
			@kingdom.world_id = session[:player_character][:in_world]
			@kingdom.bigy = session[:player_character][:bigy]
			@kingdom.bigx = session[:player_character][:bigx]
	
			unless @kingdom.save!
				@flash[:notice] = "Failed to save new kingdom"
				delete_objects
				render :action => 'spawn_kingdom'
				return
		end
		end
		
		#MAKE CASTLE EVENT
		@castle = Event.sys_gen("\nCastle #{@kingdom.name} event",														SpecialCode.get_code('event_type','castle'),														SpecialCode.get_code('event_rep_type','unlimited'),														nil)
		if !@castle.save
			@flash[:notice] = "Failed to save castle event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#MAKE THRONE EVENT
		@throne = Event.sys_gen("\nThrone #{@kingdom.name} event",														SpecialCode.get_code('event_type','throne'),														SpecialCode.get_code('event_rep_type','unlimited'),														nil)
		if !@throne.save
			@flash[:notice] = "Failed to save throne event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#MAKE CASTLE FEATURE
		#TAKE CARE OF IMAGE HERE
		@image = Image.find(:first, :conditions => ['name = ? and kingdom_id = ? and player_id = ?', 'DEFAULT CASTLE', -1, -1])
		@new_image = Image.deep_copy(@image)
		@new_image.kingdom_id = @kingdom.id
		@new_image.name = @kingdom.name + " Castle Image"
		@new_image.save
		#/ IMAGE SETUP CODE
		@castle_feature = Feature.sys_gen("\nCastle #{@kingdom.name}", @new_image.id)
		
		if !@castle_feature.save
			flash[:notice] = "Failed to save the castle feature"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#make throne and castle feature event links
		@castle_fe = FeatureEvent.new
		@castle_fe.feature_id = @castle_feature.id
		@castle_fe.event_id = @castle.id
		@castle_fe.chance = 100.0
		@castle_fe.priority = 42
		@castle_fe.choice = true
		if !@castle_fe.save
			flash[:notice] = "Failed to save the castle feature event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		@throne_fe = FeatureEvent.new
		@throne_fe.feature_id = @castle_feature.id
		@throne_fe.event_id = @throne.id
		@throne_fe.chance = 100.0
		@throne_fe.priority = 42
		@throne_fe.choice = true
		if !@throne_fe.save
			flash[:notice] = "Failed to save the throne feature event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		
		#MAKE LEVEL 0
		@level = Level.new
		@level.kingdom_id = @kingdom.id
		@level.level = 0
		@level.maxy = 3
		@level.maxx = 5
		if @level.save
			LevelMap.gen_level_map_squares(@level, @emtpy_feature)
			flash[:notice] = 'Level ' + @level.level.to_s + ' was successfully created.'
			flash[:notice] += '<br/>' + @savecount.to_s + ' map squares out of ' + (@level.maxy * @level.maxx).to_s + ' created.'
		else
			flash[:notice] = "Failed to save new level 0"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#SET THE CASTLE
		@castle_location = LevelMap.new
		@castle_location.level_id = @level.id
		@castle_location.xpos = 2
		@castle_location.ypos = 1
		@castle_location.feature_id = @castle_feature.id
		if !@castle_location.save
			flash[:notice] = "Failed to save the castle to the levelmap"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#MAKE KINGDOM ENTRANCE EVENT
		@entrance = Event.sys_gen("\nKingdom #{@kingdom.name} entrance",														SpecialCode.get_code('event_type','move'),														SpecialCode.get_code('event_rep_type','unlimited'),														nil)
		if !@entrance.save
			@flash[:notice] = "Failed to save throne event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		#EVENT ENTRANCE
		@entrance_move = EventMove.new
		@entrance_move.event_id = @entrance.id
		@entrance_move.move_type = SpecialCode.get_code('move_type','local')
		@entrance_move.move_id = @level.id
		if !@entrance_move.save
			flash[:notice] = "Failed to save kingdom entrance event move"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#MAKE STORM GATE EVENT
		@storm_event = Event.sys_gen("\nKingdom #{@kingdom.name} storm event",														SpecialCode.get_code('event_type','storm_gate'),														SpecialCode.get_code('event_rep_type','unlimited'),														nil)
		if !@storm_event.save
			@flash[:notice] = "Failed to save storm gate event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		#EVENT STORM GATE
		@storm_event_move = EventStormGate.new
		@storm_event_move.event_id = @storm_event.id
		@storm_event_move.level_id = @level.id
		if !@storm_event_move.save
		 print @storm_event_move.errors.inspect
			flash[:notice] = "Failed to save storm gate event move"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		
		#MAKE KINGDOM ENTRANCE FEATURE
		@kingdom_entrance_feature = Feature.sys_gen("\nKingdom #{@kingdom.name} entrance", @new_image.id)
		@kingdom_entrance_feature.world_feature = true
		if !@kingdom_entrance_feature.save
			flash[:notice] = "Failed to save the kingdom entrance feature"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#MAKE KINGDOM ENTRANCE FEATURE EVENT
		@entrance_fe = FeatureEvent.new
		@entrance_fe.feature_id = @kingdom_entrance_feature.id
		@entrance_fe.event_id = @entrance.id
		@entrance_fe.chance = 100.0
		@entrance_fe.priority = 42
		@entrance_fe.choice = true
		if !@entrance_fe.save
			flash[:notice] = "Failed to save the entrance feature event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		#MAKE STORM GATE FEATURE EVENT
		@storm_gate_fe = FeatureEvent.new
		@storm_gate_fe.feature_id = @kingdom_entrance_feature.id
		@storm_gate_fe.event_id = @storm_event.id
		@storm_gate_fe.chance = 100.0
		@storm_gate_fe.priority = 42
		@storm_gate_fe.choice = true
		if !@storm_gate_fe.save
			flash[:notice] = "Failed to save the entrance feature event"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		#UPDATE THE WORLD MAP LOCATION
		#@world_map = session[:last_action]	#a world map, got this way up near the top of the action
		@new_kingdom = WorldMap.copy(@world_map)
		@new_kingdom.feature_id = @kingdom_entrance_feature.id
		
		if !@new_kingdom.save
			flash[:notice] = "Failed to save the new world map kingdom location"
			delete_objects
			render :action => 'spawn_kingdom'
			return
		end
		
		@world_map_loc.destroy	#we didn't update it, just held onto it and made new row
		
		
		#make the five guards
		@gcount = 0
		while @gcount < 5
			@gcount += 1
			@guard = Npc.gen_stock_guard(@kingdom.id)
		end
		
		#make kingdom entry limitation
		@entry_limit = KingdomEntry.new
		@entry_limit.kingdom_id = @kingdom.id
		@entry_limit.allowed_entry = SpecialCode.get_code('entry_limitations','everyone')
		@entry_limit.save
		
		flash[:notice] = "Everything seems to have worked out ok! Did the kingdom spawn correctly?"
		
		#move player into kingdom
	PlayerCharacter.transaction do
		session[:player_character].lock!
		
			session[:player_character].in_kingdom = @kingdom.id
			session[:player_character].kingdom_level = @level.id
			session[:player_character].kingdom_id = @kingdom.id		#new home kingdom for the player
		
			session[:player_character].save!
		end
		
		session[:completed] = true
		redirect_to :controller => '/game', :action => 'complete'
	end
protected

	def delete_objects
		if @entry_limit then @entry_limit.destroy end
		if @new_kingdom then @new_kingdom.destroy end
		if @entrance_fe then @entrance_fe.destroy end
		if @storm_gate_fe then @storm_gate_fe.destroy end
	 
		if @kingdom_entrance_feature then @kingdom_entrance_feature.destroy end
		
		if @storm_event_move then @storm_event_move.destroy end
		if @storm_event then @storm_event.destroy end
		if @entrance_move then @entrance_move.destroy end
		if @entrance then @entrance.destroy end
		if @castle_location then @castle_location.destroy end
		
		if @level
			@level_maps = @level.level_maps
			for lm in @level_maps
				lm.destroy
			end
			@level.destroy
		end
		
		if @throne_fe then @throne_fe.destroy end
		if @castle_fe then @castle_fe.destroy end
		if @castle_feature then @castle_feature.destroy end
		if @new_image then @new_image.destroy end
		if @throne then @throne.destroy end
		if @castle then @castle.destroy end
		if @kingdom then @kingdom.destroy end
	end
end
