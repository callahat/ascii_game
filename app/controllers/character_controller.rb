class CharacterController < ApplicationController
  before_filter :authenticate, :except => ['raise_level', 'gainlevel', 'new']
  before_filter :set_player
  before_filter :setup_pc_vars, :only => ['raise_level', 'gainlevel']

  #figure out caching later. It seems to work faster if the boot file has the cacheing
  #to true, but I can't find a cache of this pages where the books says it should be.
  #caches_page :new2

  layout 'main'

  # TODO: Clean this controller up, use nested models

  def index
    redirect_to :action => 'menu'
  end

  def menu
    #the menu for dealing with your character(s)
    @player_characters = @player.player_characters
    @active_chars = @player_characters.active
    @retired_chars = @player_characters.retired
    @dead_chars = @player_characters.dead
  end

  def choose_character
    #code to load up a character into the session to play
    @select_chars = @player.player_characters.active
    @next_action = 'do_choose'
  end

  def do_choose
    clear_fe_data
    
    @player_character = @player.player_characters.find_by(id: params[:id])
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
    @select_chars = @player.player_characters.not_deleted
    @next_action = 'do_image_update'
  end

  def do_image_update
    @image = @player.player_characters.find(params[:id]).image
  end

  def updateimage
    @image = @player.player_characters.find(params[:id]).image

    if @image.id == 0
      raise 'Should not have gotten here! PlayerCharacter image has ID zero!'
    end

    @image.image_text = params[:image][:image_text]
    if @image.save
      flash[:notice] = 'Updated character image.'
      redirect_to :action => 'menu'
    else
      flash[:notice] = 'Failed to update character image.'
      redirect_to :action => 'edit_character'
    end
  end

  def new
    #code to create a new character
    @c_classes = CClass.all.order(:name)
    @races = Race.all.order(:name)
    session[:nplayer_character] = PlayerCharacter.new
  end

  def namenew
    if session[:nplayer_character].nil?
      flash[:notice] = 'Character being created expired. Please try again'
      redirect_to :action => 'new'
    else
      @race = session[:nplayer_character].race || Race.find(params[:race_id])
      session[:nplayer_character][:race_id] ||= params[:race_id]
      session[:nplayer_character][:c_class_id] ||= params[:c_class_id]
    
      #give the character a name, pick a kingdom, let the good tiems roll
      #mainly create the player's character stats
      @kingdoms = Kingdom.where(['id > -1'])
      @player_character = session[:nplayer_character]

      @ori_image = @race.image
      @image = Image.deep_copy(@ori_image)
      @player_character.image = @image
    end
  end

  def create
    if session[:nplayer_character].nil?
      flash[:notice] = 'Character being created expired. Please try again'
      redirect_to :action => 'new'
      return
    end
  
    flash[:notice] = " "

    if params[:player_character][:image_id].present?
      params[:player_character][:image_attributes].merge!(
          Image.find(params[:player_character][:image_id]).attributes.slice('image_text','picture'))
    end

    @player_character = PlayerCharacter.new(player_character_params)
    @player_character.player_id = @player.id

    @player_character.build_image unless @player_character.image
    @player_character.image.name = "#{@player.handle}'s character image"
    @player_character.image.player_id = @player.id
    @player_character.image.kingdom_id = params[:player_character][:kingdom_id]
    @player_character.image.image_type = SpecialCode.get_code('image_type','character')
    @player_character.race_id = session[:nplayer_character][:race_id]
    @player_character.c_class_id = session[:nplayer_character][:c_class_id]

    @kingdom = @player_character.kingdom
    @player_character.bigx = @kingdom.bigx
    @player_character.bigy = @kingdom.bigy
    @player_character.in_world = @kingdom.world_id
    @player_character.kingdom_id = @kingdom.id
    @player_character.turns = 50
    @player_character.gold = 250
    @player_character.next_level_at = -1 #this should be overridden, but needed to save record

    p session[:nplayer_character]
    if @player_character.save
      flash[:notice] += 'Player character created sucessfully<br/>'
      #Clear the unneeded temporary variable
      session[:nplayer_character] = nil
      redirect_to menu_character_index_path
    else
      @kingdoms = Kingdom.where(['id > -1'])
      render :action => 'namenew'
    end
  end


  def raise_level
    @base_stats = @pc.base_stat
    @distributed_freepts = StatPc.new
    
    if @pc[:freepts] == 0
      gainlevel
    end
  end

  def gainlevel
    @base_stats = @pc.base_stat
    @distributed_freepts = StatPc.new(gain_level_params)
    
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
    @select_chars = @player.player_characters.not_deleted
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
    @select_chars = @player.player_characters.active
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
    @select_chars = @player.player_characters.retired
    @next_action = 'do_unretire'
  end

  def do_unretire
    if @player.player_characters.active.size >= 3
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
    session[:ev_choice_ids] = nil
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

  def player_character_params
    params.require(:player_character).permit(
        :name,
        :kingdom_id,
        image_attributes: [:image_text,:picture])
  end

  def gain_level_params
    params.require(:distributed_freepts).permit(:str, :dex, :con, :int, :mag, :dfn, :dam)
  end

  def set_player
    @player = current_player
  end
end
