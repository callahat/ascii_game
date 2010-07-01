class CharacterController < ApplicationController
	before_filter :authenticate, :except => ['raise_level', 'gainlevel', 'new']
	before_filter :setup_pc_vars, :only => ['raise_level', 'gainlevel']

	#figure out caching later. It seems to work faster if the boot file has the cacheing
	#to true, but I can't find a cache of this pages where the books says it should be.
	#caches_page :new2

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :do_destroy, :do_retire, :do_unretire, :do_choose, :do_image_update, :updateimage, :create ],				 :redirect_to => { :action => :menu }

	def index
		redirect_to :action => 'menu'
	end

	def menu
		#the menu for dealing with your character(s)
		@player_characters = @player.player_characters
		@active_chars = @player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code("char_stat","active")])
		@retired_chars = @player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code("char_stat","retired")])
		@dead_chars = @player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code("char_stat","final death")])
	end

	def choose_character
		#code to load up a character into the session to play
		@select_chars = @player.player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code("char_stat","active")])
		@next_action = 'do_choose'
	end

	def do_choose
		clear_fe_data
		
		@player_character = @player.player_characters.find(:first, :conditions => ['id = ?', params[:id]])
		if @player_character
			session[:player_character] = nil
			session[:player_character] = @player_character
			flash[:notice] = 'Character "' + session[:player_character].name + '" loaded!'
			redirect_to :controller => 'game', :action => 'main'
		else
			flash[:notice] = 'Unable to load character'
			redirect_to :action => 'choose_character'
		end
	end

	def edit_character
		#code to load up a character into the session to play
		@select_chars = @player.player_characters.find(:all, :conditions => ['char_stat != ?', SpecialCode.get_code("char_stat","deleted")])
		@next_action = 'do_image_update'
	end

	def do_image_update
		@image = Image.find(@player.player_characters.find(params[:id]).image_id)
	end

	def updateimage
		@player_character = @player.player_characters.find(params[:id])
		@image = Image.find(@player_character.image_id.to_i)
		if @image.id == 0
			@image = Image.new
			@image.player_id = @player.id
			@image.image_text = params[:image][:image_text]
			@image.public = 'false'
			@image.image_type = SpecialCode.get_code('image_type','character')
			@image.name = @player_character.name + ' character image'
			if @image.save
				flash[:notice] = 'Created character image.'
				redirect_to :action => 'menu'
			else
				flash[:notice] = 'Failed to create character image.'
				redirect_to :action => 'edit_character'	
			end
		else
			@image.image_text = params[:image][:image_text]
			if @image.save
				flash[:notice] = 'Updated character image.'
				redirect_to :action => 'menu'
			else
				flash[:notice] = 'Failed to update character image.'
				redirect_to :action => 'edit_character'
			end
		end
	end

	def new
		#code to create a new character
		@c_classes = CClass.find(:all,:order => 'name')
		@races = Race.find(:all,:order => 'name')
		session[:nplayer_character] = PlayerCharacter.new
	end

	def namenew
		if session[:nplayer_character].nil?
			flash[:notice] = 'Character being created expired. Please try again'
			redirect_to :action => 'new'
		else
			@race = Race.find(params[:race_id])
			session[:nplayer_character][:race_id] = params[:race_id]
			session[:nplayer_character][:c_class_id] = params[:c_class_id]
		
			#give the character a name, pick a kingdom, let the good tiems roll
			#mainly create the player's character stats
			@kingdoms = Kingdom.find(:all, :conditions => ['id > -1'])
			@player_character = session[:nplayer_character]

			@ori_image = @race.image
			@image = Image.deep_copy(@ori_image)
		end
	end

	def create
		if session[:nplayer_character].nil?
			flash[:notice] = 'Character being created expired. Please try again'
			redirect_to :action => 'new'
		end
	
		flash[:notice] = " "
		#code to save off the new character image
		#if no image, then player gets default, otherwise if player has default and there
		#is an image in the param, then make the image. Otherwise, the player already has
		#this image.
		if params[:image][:image_text].nil? && session[:nplayer_character][:image_id].nil?
			session[:nplayer_character][:image_id] = 0
		elsif params[:image][:image_text] != ""
			if session[:nplayer_character][:image_id].to_i == 0
				@image = Image.new
				@image.player_id = @player.id
				@image.public = 'false'
				@image.kingdom_id = params[:kingdom][:id].to_i
				@image.image_type = SpecialCode.get_code('image_type','character')
				@image.image_text = params[:image][:image_text]
				@image.name = @player.handle + '\'s character image'
			
				if @image.save
					flash[:notice] += @image.name + ' was successfully created.<br/>'
					session[:nplayer_character][:image_id] = @image.id
					#redirect_to :action => 'create'
				else
					flash[:notice] += 'Image was not sucessfully created.<br/>'
					redirect_to :action => 'namenew'
					return
				end
			else
				@image = Image.find(session[:nplayer_character][:image_id])
				@image.image_text = params[:image][:image_text]
				if @image.save
					flash[:notice] += @image.name + ' was successfully updated.<br/>'
					session[:nplayer_character][:image_id] = @image.id
					#redirect_to :action => 'create'
				else
					flash[:notice] += 'Image was not sucessfully updated.<br/>'
					redirect_to :action => 'namenew'
					return
				end
			end
		end
		#end of image handling

		session[:nplayer_character][:name] = params[:player_character][:name]
		session[:nplayer_character][:player_id] = @player.id

		@kingdom = Kingdom.find(:first, :conditions => ['id = ?', params[:kingdom][:id].to_i])
		session[:nplayer_character][:bigx] = @kingdom.bigx
		session[:nplayer_character][:bigy] = @kingdom.bigy
		session[:nplayer_character][:in_world] = @kingdom.world_id
		session[:nplayer_character][:kingdom_id] = @kingdom.id
		session[:nplayer_character][:turns] = 50
		session[:nplayer_character][:gold] = 250
		session[:nplayer_character][:next_level_at] = -1 #this should be overridden, but needed to save record
		
		p session[:nplayer_character]
		if (pc = PlayerCharacter.create(session[:nplayer_character].attributes)).errors.size == 0
			flash[:notice] += 'Player character created sucessfully<br/>'
		else
			session[:nplayer_character] = pc
			redirect_to :action => 'namenew'
			return
		end

		#make the player character equip loc rows!
		@equip_locs = RaceEquipLoc.find(:all, :conditions => ['race_id = ?', pc[:race_id]])
		#but make sure they haven't already been populate!
		@pc_equip_locs = PlayerCharacterEquipLoc.find(:all, :conditions => ['player_character_id = ?', pc[:id]])

		if @pc_equip_locs.size >= @equip_locs.size
			flash[:notice] += 'Equiplocs already created!<br/>'
		else
			for equip_loc in @equip_locs
				loc = PlayerCharacterEquipLoc.new
				loc[:player_character_id] = pc[:id]
				loc[:equip_loc] = equip_loc[:equip_loc]
				loc[:item_id] = nil
				if !loc.save
					flash[:notice] += loc[:equip_loc] + 'Failed in creation; <br/>'
				end
			end
		end
		#Clear the unneeded temporary variable
		session[:nplayer_character] = nil
		redirect_to :controller => 'character', :action => 'menu'
	end


	def raise_level
		@base_stats = @pc.base_stat
		@distributed_freepts = StatPc.new(params[:distributed_freepts])
		
		if @pc[:freepts] == 0
			redirect_to :action => 'gainlevel'
		end
	end

	def gainlevel
		@base_stats = @pc.base_stat
		@distributed_freepts = StatPc.new(params[:distributed_freepts])
		
		@goback, @message = @pc.gain_level(@distributed_freepts)
		if @goback == 0
			render :action => 'raise_level'
		else
			flash[:notice] = @message
			redirect_to :controller => 'game', :action => 'main'
		end
	end

	def destroy
		#code to delete a character completely. Don't know why someone
		#would want to do this, as they can have several chars. Unless
		#its a soft game where characters never really die.
		@select_chars = @player.player_characters.find(:all, :conditions => ['char_stat != ?', SpecialCode.get_code("char_stat","deleted")])
		@next_action = 'do_destroy'
	end

	def do_destroy
		clear_fe_data
	
		@c=@player.player_characters.find(params[:id])
		@c.char_stat = SpecialCode.get_code("char_stat","deleted")
		
		#unselect current character if its getting deleted
		if session[:player_character] && @c.id == session[:player_character].id
			session[:player_character] = nil
		end
		if @c.save
			flash[:notice] = 'Character "' + @c.name + '" has been destroyed.'

			#call to the routien which clears out the character specific records which are removed
			#when a character is destroyed.
			#this is like retirement, only the player can't go back on it ever.
			killdata
			@c.player_character_equip_locs.destroy_all
			redirect_to :action => 'menu'
		else
			flash[:notice] = 'An error occurred, please try again'
			redirect_to :action => 'delete'
		end
	end

	def final_death
		#For characters who meet their final demise and can't be played
		#anymore. Really only counts in hardcore games where death
		#is permanent (unless resurection spells become available).
		clear_fe_data
		flash[:notice] = 'The character has met with final death. Bandits looted the corpse'
		redirect_to :action => 'menu'
	end

	def retire
		#For players who dont want to destroy the character, just not
		#play them anymore. These players lose all their stuff, but keep
		#their stats and other attributes, as well as what they are
		#equipped with. All gold and inventory items are forfit though.
		@select_chars = @player.player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code("char_stat","active")])
		@next_action = 'do_retire'
	end

	def do_retire
		clear_fe_data
	
		@c=@player.player_characters.find(params[:id])
		@c.char_stat = SpecialCode.get_code("char_stat","retired")
		@c.gold = 0
		
		#unselect current character if its getting deleted
		if session[:player_character] && @c.id == session[:player_character].id
			session[:player_character] = nil
		end
		
		if @c.save
			flash[:notice] = 'Character "' + @c.name + '" has been retired.'
			#call to the routien which clears out the character specific records which are removed
			#when a character is retired.
			killdata

			redirect_to :action => 'menu'
		else
			flash[:notice] = 'An error occurred, please try again'
			redirect_to :action => 'retire'
		end
	end

	def unretire
		#Bring a character back into action. Make sure this won't bring
		#the player's number of active characters over the limit though.
		@select_chars = @player.player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code("char_stat","retired")])
		@next_action = 'do_unretire'
	end

	def do_unretire
		if @player.player_characters.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code("char_stat","active")]).size >= 3
			flash[:notice] = 'Cannot have more than three active characters.'
			redirect_to :action => 'menu'
			return
		end
	
		@c=@player.player_characters.find(params[:id])
		@c.char_stat = SpecialCode.get_code("char_stat","active")
		if @c.save
			flash[:notice] = 'Character "' + @c.name + '" has been brought back from retirement.'
			redirect_to :action => 'menu'
		else
			flash[:notice] = 'An error occurred, please try again'
			redirect_to :action => 'unretire'
		end
	end

	def rise_from_the_grave
		#For characters who are risen from the grave
	end
	
protected
	def clear_fe_data
		#gotta clear out the actions from the last turn
		session[:last_action] = nil
		session[:fe_chain] = nil
		session[:current_event] = nil
		session[:fe_curpri] = nil
	end

	def killdata
		@c.items.destroy_all 
		for lq in @c.log_quests
			lq.creature_kills.destroy_all
			lq.explores.destroy_all
			lq.kill_n_npcs.destroy_all
			lq.kill_pcs.destroy_all
			lq.kill_s_npcs.destroy_all
		end
		@c.log_quests.destroy_all
		@c.illnesses.destroy_all
	end
end
