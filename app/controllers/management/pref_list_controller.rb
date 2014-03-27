class Management::PrefListController < ApplicationController
	before_filter :authenticate
	before_filter :king_filter

	layout 'main'

#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :drop_from_list, :add_to_list ], :redirect_to => { :action => :index }

	def index
		@stuff = session[:pref_list_type].eligible_list(session[:player][:id], session[:kingdom][:id])
		@pref_list = session[:pref_list_type].current_list(session[:kingdom])
		session[:cur_pref_list_class] = @stuff.collect{|s| s.id}

		@all_things = @stuff.paginate(:page => params[:page])
	end
	
	def add_to_list
		if session[:cur_pref_list_class].index(params[:id].to_i).nil?
			flash[:notice] = "Invalid ID number"
		else
			session[:pref_list_type].add(session[:kingdom][:id], params[:id])
		end

		redirect_to :action => 'index', :page => params[:page]
	end
	
	def drop_from_list
		session[:pref_list_type].drop(session[:kingdom][:id], params[:id])
		
		redirect_to :action => 'index', :page => params[:page]
	end
end
