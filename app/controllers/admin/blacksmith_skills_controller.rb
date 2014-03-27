class Admin::BlacksmithSkillsController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin
	
	layout 'admin'

	def index
		list
		render :action => 'list'
	end

#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],
#				 :redirect_to => { :action => :list }

	def list
		@blacksmith_skills = BlacksmithSkill.get_page(params[:page])
	end

	def show
		@blacksmith_skill = BlacksmithSkill.find(params[:id])
	end

	def new
		@blacksmith_skill = BlacksmithSkill.new
	end

	def create
		@blacksmith_skill = BlacksmithSkill.new(params[:blacksmith_skill])
		if @blacksmith_skill.save
			flash[:notice] = 'BlacksmithSkill was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@blacksmith_skill = BlacksmithSkill.find(params[:id])
	end

	def update
		@blacksmith_skill = BlacksmithSkill.find(params[:id])
		if @blacksmith_skill.update_attributes(params[:blacksmith_skill])
			flash[:notice] = 'BlacksmithSkill was successfully updated.'
			redirect_to :action => 'show', :id => @blacksmith_skill
		else
			render :action => 'edit'
		end
	end

	def destroy
		BlacksmithSkill.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
