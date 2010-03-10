class Admin::NpcsController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin
	
	layout 'admin'

	def index
		session[:kingdom][:id] = -1
		list
		render :action => 'list'
	end

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
				 :redirect_to => { :action => :list }

	def list
		@npcs = Npc.get_page(params[:page])
	end

	def show
		@npc = Npc.find(params[:id])
	end

	def new
		@npc = Npc.new
		@stat = StatNpc.new
		@health = HealthNpc.new
		@divisions = [ ['merchant', SpecialCode.get_code('npc_division', 'merchant')],
									 ['guard', SpecialCode.get_code('npc_division', 'guard')] ]
	end

	def create
		@npc = Npc.new(params[:npc])
		@stat = StatNpc.new(params[:stat])
		@health = HealthNpc.new(params[:health])
		@divisions = [ ['merchant', SpecialCode.get_code('npc_division', 'merchant')],
									 ['guard', SpecialCode.get_code('npc_division', 'guard')] ]
		if @stat.valid? & @health.valid? & @npc.save
			@stat.owner_id = @npc.id
			@health.owner_id = @npc.id
			@stat.save
			@health.save
			flash[:notice] = 'Npc was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@npc = Npc.find(params[:id])
		@stat = @npc.stat
		@health = @npc.health
		@divisions =	[ ['merchant', SpecialCode.get_code('npc_division', 'merchant')],
									 ['guard', SpecialCode.get_code('npc_division', 'guard')] ]
	end

	def update
		@npc = Npc.find(params[:id])
		@stat = @npc.stat
		@health = @npc.health
		@divisions = [ ['merchant', SpecialCode.get_code('npc_division', 'merchant')],
									 ['guard', SpecialCode.get_code('npc_division', 'guard')] ]
		if @stat.update_attributes(params[:stat]) &
					@health.update_attributes(params[:health]) &
					@npc.update_attributes(params[:npc])
			flash[:notice] = 'Npc was successfully updated.'
			redirect_to :action => 'show', :id => @npc
		else
			render :action => 'edit'
		end
	end

	def destroy
		Npc.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
