class Management::KingdomEntriesController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	def index
		show
		render :action => 'show'
	end

#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :update ],				 :redirect_to => { :action => :show }


	def show
		@kingdom_entry = session[:kingdom].kingdom_entry
	end

	def edit
		@kingdom_entry = KingdomEntry.find(:first, :conditions => ['kingdom_id = ?', session[:kingdom][:id]])
		@entry_types = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'entry_limitations'])
	end

	def update
		@kingdom_entry = KingdomEntry.find(:first, :conditions => ['kingdom_id = ?', session[:kingdom][:id]])
		@kingdom_entry.allowed_entry = params[:kingdom_entry][:allowed_entry]
		if @kingdom_entry.save
			flash[:notice] = 'KingdomEntry was successfully updated.'
			redirect_to :action => 'show'
		else
			render :action => 'edit'
		end
	end
end
