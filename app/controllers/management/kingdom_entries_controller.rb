class Management::KingdomEntriesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter

  layout 'main'

  def index
    show
    render :action => 'show'
  end

  def show
    @kingdom_entry = session[:kingdom].kingdom_entry
  end

  def edit
    @kingdom_entry = KingdomEntry.find_by(kingdom_id: session[:kingdom][:id])
    @entry_types = SpecialCode.get_codes_and_text('entry_limitations')
  end

  def update
    @kingdom_entry = KingdomEntry.find_by(kingdom_id: session[:kingdom][:id])
    @kingdom_entry.allowed_entry = params[:kingdom_entry][:allowed_entry]
    if @kingdom_entry.save
      session[:kingdom].reload
      flash[:notice] = 'KingdomEntry was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
end
