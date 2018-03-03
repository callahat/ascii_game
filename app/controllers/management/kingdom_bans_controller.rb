class Management::KingdomBansController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter

  layout 'main'

  def index
    list
    render :action => 'list'
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],         :redirect_to => { :action => :list }

  def list
    @kingdom_bans = KingdomBan.get_page(params[:page], session[:kingdom][:id])
  end

  def show
    @kingdom_ban = KingdomBan.find(params[:id])
  end

  def new
    @kingdom_ban = KingdomBan.new
  end

  def create
    @kingdom_ban = KingdomBan.new(params[:kingdom_ban])
    @kingdom_ban.kingdom_id = session[:kingdom][:id]
    @kingdom_ban.player_character_id = PlayerCharacter.find_by(name: params[:kingdom_ban][:name]).id
    
    if @kingdom_ban.save
      flash[:notice] = @kingdom_ban.name + ' was banned.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def destroy
    KingdomBan.find(params[:id]).destroy
    redirect_to :action => 'list', :page => params[:page]
  end
end
