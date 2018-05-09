class Management::KingdomNoticesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :setup_king_pc_vars
  before_filter :set_kingdom

  layout 'main'

  def index
    @kingdom_notices = KingdomNotice.get_page(params[:page], nil, @kingdom )
  end

  def new
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = KingdomNotice.new signed: "Your King, #{@kingdom.player_character.name}"
  end

  def create
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = @kingdom.kingdom_notices.new(kingdom_notice_params)
    if @kingdom_notice.save
      flash[:notice] = 'KingdomNotice was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = @kingdom.kingdom_notices.find(params[:id])
  end

  def update
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = @kingdom.kingdom_notices.find(params[:id])

    if @kingdom_notice.update_attributes(kingdom_notice_params)
      flash[:notice] = 'KingdomNotice was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @kingdom.kingdom_notices.destroy(params[:id])
    flash[:notice] = "Censored!"
    redirect_to :action => 'index', :page => params[:page]
  end
  
  protected

  def kingdom_notice_params
    params.require(:kingdom_notice).permit(:text, :shown_to, :signed)
  end

  def set_kingdom
    @kingdom = session[:kingdom]
  end
end
