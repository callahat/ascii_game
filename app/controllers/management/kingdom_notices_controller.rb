class Management::KingdomNoticesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :setup_king_pc_vars

  layout 'main'

  def index
    @kingdom_notices = KingdomNotice.get_page(params[:page], nil, session[:kingdom] )
  end

  def new
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = KingdomNotice.new signed: "Your King, #{session[:kingdom].player_character.name}"
  end

  def create
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = KingdomNotice.new(params[:kingdom_notice])
    @kingdom_notice.kingdom_id = session[:kingdom][:id]
    if @kingdom_notice.save
      flash[:notice] = 'KingdomNotice was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = KingdomNotice.find_by(id: params[:id])
  end

  def update
    @shows = SpecialCode.get_codes_and_text('shown_to')
    @kingdom_notice = KingdomNotice.find_by(id: params[:id])

    if verify_notice_owner and @kingdom_notice.update_attributes(params[:kingdom_notice])
      flash[:notice] = 'KingdomNotice was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @kingdom_notice = KingdomNotice.find_by(id: params[:id])

    flash[:notice] = "Censored!"

    verify_notice_owner and @kingdom_notice.destroy
    redirect_to :action => 'index', :page => params[:page]
  end
  
protected
  def verify_notice_owner
    if session[:kingdom][:id] != @kingdom_notice.kingdom_id
      flash[:notice] = "Invalid notice"
      return false
    else
      return true
    end
  end
end
