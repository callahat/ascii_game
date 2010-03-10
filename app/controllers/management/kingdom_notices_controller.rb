class Management::KingdomNoticesController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	def index
		list
		render :action => 'list'
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :list }

	def list
		@kingdom_notices = KingdomNotice.get_page(params[:page], session[:kingdom].id )
	end

	def new
		@shows = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'shown_to'])
		@kingdom_notice = KingdomNotice.new
	end

	def create
		@shows = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'shown_to'])
		@kingdom_notice = KingdomNotice.new(params[:kingdom_notice])
		@kingdom_notice.datetime = Time.now.strftime("%I:%M%p %m/%d/%Y")
		@kingdom_notice.kingdom_id = session[:kingdom][:id]
		if @kingdom_notice.save
			flash[:notice] = 'KingdomNotice was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@shows = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'shown_to'])
		@kingdom_notice = KingdomNotice.find(:first, :conditions => ['id = ?', params[:id]])
	end

	def update
		@shows = SpecialCode.find(:all, :conditions => ['spec_col_type = ?', 'shown_to'])
		@kingdom_notice = KingdomNotice.find(:first, :conditions => ['id = ?', params[:id]])
		
		verify_notice_owner
		
		if @kingdom_notice.update_attributes(params[:kingdom_notice])
			flash[:notice] = 'KingdomNotice was successfully updated.'
			redirect_to :action => 'list'
		else
			render :action => 'edit'
		end
	end

	def destroy
		@kingdom_notice = KingdomNotice.find(:first, :conditions => ['id = ?', params[:id]])
		verify_notice_owner
	
		@kingdom_notice.destroy
		redirect_to :action => 'list', :page => params[:page]
	end
	
protected
	def verify_notice_owner
		if session[:kingdom][:id] != @kingdom_notice.kingdom_id
			redirect_to :action => 'list'
			return false
		else
			return true
		end
	end
end
