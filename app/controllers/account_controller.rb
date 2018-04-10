class AccountController < ApplicationController
  before_filter :authenticate, only: [:index,:show,:edit,:update]
  before_filter :is_admin, only: [:index]
  before_filter :set_player, only: [:show,:edit,:update]

  layout 'main'

  # TODO: split some of this stuff off into admin/accounts controller. This controller should really only show/edit the account of the individual signed in

  def index
    @players = Player.get_page(params[:page])
  end

  def show
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    @player.account_status = SpecialCode.get_code('account_status','active')
    # TODO: mod table and rename joined to created_at
    @player.joined = Time.now

    if true || verify_recaptcha
      if @player.save
        flash[:notice] = 'Player was successfully created.'
        session[:player] = @player
        if params[:race_id] != "" || params[:c_class_id] != ""
          redirect_to :controller => 'character', :action => 'namenew', :race_id => params[:race_id], :c_class_id => params[:c_class_id]
        else
          redirect_to :controller => 'character', :action => 'menu'
        end
      else
        render :action => 'new'
      end
    else
      # flash.delete(:recaptcha_error) # get rid of the recaptcha error being flashed by the gem.
      flash[:error] = 'reCAPTCHA is incorrect. Please try again.'
      render :action => 'new'
    end
  end

  def edit
    @player.passwd = ""
  end

  def update
    if @player.update_attributes(player_params)
      flash[:notice] = 'Player was successfully updated.'
      redirect_to :action => 'show', :id => @player
    else
      render :action => 'edit'
    end
  end

  #Accounts won't be able to be destroyed, but deleted. Keep the data, restrict the access.
  #def destroy
  #  Player.find(params[:id]).destroy
  #  redirect_to :action => 'index'
  #end

  #validate the player
  def verify
    if params.nil? || params[:player].nil? || params[:player][:passwd].nil? || params[:player][:handle].nil? then
      redirect_to login_path
      return false
    end

    @player = Player.authenticate(params[:player][:handle],params[:player][:passwd])
    if @player.nil? ||
        !Player.authenticate?(params[:player][:handle],params[:player][:passwd])
      flash[:notice] = "Invalid handle/password."
      redirect_to login_path
    else
      session[:player] = @player
      redirect_to menu_character_index_path
    end
  end

  def login
    if flash[:notice].nil?
      reset_session
    end
  end

  def logout
    reset_session
    redirect_to :action => 'login'
  end

  def what
  end

protected
  def verify_player_is_player
    if session[:player][:id] != @player.id
      flash[:notice] = 'You are not logged in as this player'
      false
    else
      true
    end
  end

  def player_params
    params.require(:player).permit(:handle,:passwd,:city,:state,:country,:email,:bio)
  end

  def set_player
    @player = Player.find(params[:id])
    unless session[:player].admin or verify_player_is_player
      redirect_to menu_character_index_path
      return
    end
  end
end
