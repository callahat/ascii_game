class Management::KingdomBansController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :setup_king_pc_vars

  layout 'main'

  def index
    @kingdom_bans = KingdomBan.get_page(params[:page], session[:kingdom][:id])
  end

  def show
    @kingdom_ban = KingdomBan.find(params[:id])
  end

  def new
    @kingdom_ban = KingdomBan.new
  end

  def create
    @kingdom_ban = session[:kingdom].kingdom_bans.new(kingdom_ban_params)
    @kingdom_ban.player_character_id = PlayerCharacter.find_by(name: kingdom_ban_params[:name]).try :id
    
    if @kingdom_ban.save
      flash[:notice] = @kingdom_ban.name + ' was banned.'
      redirect_to management_kingdom_bans_path page: params[:page]
    else
      render :action => 'new'
    end
  end

  def destroy
    KingdomBan.find(params[:id]).destroy
    redirect_to management_kingdom_bans_path page: params[:page]
  end

  protected

  def kingdom_ban_params
    params.require(:kingdom_ban).permit(:name)
  end
end
