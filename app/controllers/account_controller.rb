class AccountController < ApplicationController
  layout 'main'

  def index
    list
    render :action => 'list'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :list }

  def list
    @players = Player.get_page(params[:page])
  end

  def show
    @player = Player.find(params[:id])
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(params[:player])
    
    @player.account_status = SpecialCode.get_code('account_status','active')
    @player.admin = false
    @player.joined = Time.now
    
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
  end

  def edit
    @player = Player.find(params[:id])
    @player.passwd = ""
  end

  def update
    @player = Player.find(params[:id])
    if !verify_player_is_player
      redirect_to :controller => 'character', :acton => 'menu'
      return
    end
    
    if @player.update_attributes(params[:player])
      flash[:notice] = 'Player was successfully updated.'
      redirect_to :action => 'show', :id => @player
    else
      render :action => 'edit'
    end
  end

  #Accounts won't be able to be destroyed, but deleted. Keep the data, restrict the access.
  #def destroy
  #  Player.find(params[:id]).destroy
  #  redirect_to :action => 'list'
  #end

  #validate the player
  def verify
    if params.nil? || params[:player].nil? || params[:player][:passwd].nil? || params[:player][:handle].nil? then
      redirect_to :action => 'login'
      return false
    end

    @player = Player.authenticate(params[:player][:handle],params[:player][:passwd])
    if @player.nil? || 
        !Player.authenticate?(params[:player][:handle],params[:player][:passwd])
      flash[:notice] = "Invalid handle/password."
      redirect_to :action => 'login'
    else
      session[:player] = @player
      redirect_to :controller => 'character', :action => 'menu'
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
end
