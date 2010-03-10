class Admin::NameTitlesController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin
	
	layout 'admin'

	def index
		list
		render :action => 'list'
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
				 :redirect_to => { :action => :list }

	def list
		@name_titles = NameTitle.get_page(params[:page])
	end

	def show
		@name_title = NameTitle.find(params[:id])
	end

	def new
		@name_title = NameTitle.new
		@stats = ["","all","con","dam","dex","dfn","int","mag","str"]
	end

	def create
		@name_title = NameTitle.new(params[:name_title])
		@stats = ["","all","con","dam","dex","dfn","int","mag","str"]
		if @name_title.save
			flash[:notice] = 'NameTitle was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@name_title = NameTitle.find(params[:id])
		@stats = ["","all","con","dam","dex","dfn","int","mag","str"]
	end

	def update
		@name_title = NameTitle.find(params[:id])
		@stats = ["","all","con","dam","dex","dfn","int","mag","str"]
		if @name_title.update_attributes(params[:name_title])
			flash[:notice] = 'NameTitle was successfully updated.'
			redirect_to :action => 'show', :id => @name_title
		else
			render :action => 'edit'
		end
	end

	def destroy
		NameTitle.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
