class Management::PrefListController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :drop_from_list, :add_to_list ],				 :redirect_to => { :action => :index }

	def index
		if session[:pref_list_type] == :creature
			@pref_list = session[:kingdom].creature_pref_list
		elsif session[:pref_list_type] == :event
			@pref_list = session[:kingdom].event_pref_list
		elsif session[:pref_list_type] == :feature
			@pref_list = session[:kingdom].feature_pref_list
		else
			redirect_to :controller => '/management'
			return
		end
		
		#@all_things = PrefList.get_page(params[:page], ['kingdom_id = ?', session[:kingdom][:id]])
		@all_things = @pref_list.paginate(:page => params[:page])
	end
	
	def add_to_list
		if !session[:cur_pref_list_class].exists?(params[:id])
			flash[:notice] = "Invalid ID number"
		elsif find_thing_on_list.nil?
			@new_list_thing = PrefList.new
			@new_list_thing.kingdom_id = session[:kingdom][:id]
			@new_list_thing.thing_id = params[:id]
			@new_list_thing.pref_list_type = SpecialCode.get_code('pref_list_type',session[:cur_pref_list_class].table_name)
			@new_list_thing.save
		end

		redirect_to :action => 'index', :page => params[:page]
	end
	
	def drop_from_list
		if (@list_thing = find_thing_on_list)
			@list_thing.destroy
		end
		
		redirect_to :action => 'index', :page => params[:page]
	end

protected
	def find_thing_on_list
		if session[:pref_list_type] == :creatures
			session[:kingdom].creature_pref_list.find(:first, :conditions => ['thing_id = ?', params[:id]])
		elsif session[:pref_list_type] == :events
			session[:kingdom].event_pref_list.find(:first, :conditions => ['thing_id = ?', params[:id]])
		elsif session[:pref_list_type] == :features
			session[:kingdom].feature_pref_list.find(:first, :conditions => ['thing_id = ?', params[:id]])
		end
	end
end
