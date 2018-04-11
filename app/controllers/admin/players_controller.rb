class Admin::PlayersController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin
  before_filter :set_player, only: [:show,:edit,:update]

  layout 'admin'

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

    if @player.save
      flash[:notice] = 'Player was successfully created.'
      redirect_to admin_player_path(@player)
    else
      render :action => 'new'
    end
  end

  def edit
    @player.passwd = ""
  end

  def update
    if @player.update_attributes(player_params)
      flash[:notice] = 'Player was successfully updated.'
      redirect_to [:admin,@player]
    else
      render :action => 'edit'
    end
  end

  #Accounts won't be able to be destroyed, but deleted. Keep the data, restrict the access.
  #def destroy
  #  Player.find(params[:id]).destroy
  #  redirect_to admin_players_path
  #end

protected
  def player_params
    params.require(:player).permit(:handle,:passwd,:city,:state,:country,:email,:bio)
  end

  def set_player
    @player = Player.find(params[:id])
  end
end
