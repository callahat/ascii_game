class ManagementController < ApplicationController
  include KingdomManagement

  def choose_kingdom
    session[:kingdom] = nil
    main_index
    render :action => 'main_index'
  end

  def main_index
    if session[:kingdom].nil? || @pc.nil?
      #code for regular menu to do things
      #Have the player pick a kingdom to manage, they mgith have multiple
      #Kingdoms depending on their characters in play
      @pcs = current_player.player_characters
      @kingdoms = Array.new

      #get the kingdoms for the drop down menu
      for pc in @pcs
        @kingdoms.concat pc.kingdoms.order(:name)
      end
    end
  end

  def helptext
  end

  def select_kingdom
    @kingdom = Kingdom.find(params[:king][:kingdom_id])
    if current_player.player_characters.find(@kingdom.player_character_id)
      session[:kingdom] = @kingdom
    else
      flash[:notice] = 'You are not the king in the kingdom submitted!'
    end
    redirect_to :action => 'main_index'
  end

  def retire
    if session[:kingdom].nil?
      redirect_to :action => 'retire'
      return
    elsif params[:commit] == "Abandon"
      @no_king = true
      @message = 'Really leave the kingdom without a monarch?'
    elsif params[:new_king]
      print "in here"
      @player_character = PlayerCharacter.find_by(name: params[:new_king])
      session[:new_king] = @player_character
      if @player_character.nil?
        @message = 'No such character by the name "' + params[:new_king] + '" was found.'
      elsif @player_character.kingdom
        @message = 'Really hand the throne over to ' + @player_character.name + ' of ' + @player_character.kingdom.name + '?'
      else
        @message = 'Really hand the throne over to ' + @player_character.name + '?'
      end
    end
  end

  def do_retire
    if params[:commit] == "Cancel"
      session[:new_king] = nil
      redirect_to :action => 'retire'
    else
      if session[:new_king]
        @player_character = PlayerCharacter.find_by(name: session[:new_king].name)
      end
      if @player_character.nil?
        @pc_id = nil
        @message = session[:kingdom].player_character.name + " has abandonded their position as king of " + session[:kingdom].name + ", designating no sucessor."
      else
        @pc_id = @player_character.id
        @message = session[:kingdom].player_character.name + " has abdicated rule of " + session[:kingdom].name + " to " + @player_character.name
      end

      @kingdom = session[:kingdom]
      @kingdom.player_character_id = @pc_id

      if @kingdom.save
        flash[:notice] = 'You have relinquished the crown of ' + @kingdom.name

        #New kingdom notice
        KingdomNotice.create_notice(@message, @kingdom.id)
      end

      session[:kingdom] = nil
      session[:new_king] = nil
      session[:kingbit] = false

      redirect_to :controller => 'game', :action => "main"
    end
  end
end
