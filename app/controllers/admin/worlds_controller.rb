class Admin::WorldsController < ApplicationController
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
		@worlds = World.get_page(params[:page])
	end

	def show
		@world = World.find(params[:id])
	end

	def new
		@world = World.new
	end

	def create
		@world = World.new(params[:world])
		if @world.save
			flash[:notice] = 'World was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@world = World.find(params[:id])
	end

	def update
		@world = World.find(params[:id])
		if @world.update_attributes(params[:world])
			flash[:notice] = 'World was successfully updated.'
			redirect_to :action => 'show', :id => @world
		else
			render :action => 'edit'
		end
	end

	#def destroy
	#	World.find(params[:id]).destroy
	#	redirect_to :action => 'list'
	#end
end
