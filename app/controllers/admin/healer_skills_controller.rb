class Admin::HealerSkillsController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin
	
	layout 'admin'

	def index
		list
		render :action => 'list'
	end

#	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#	verify :method => :post, :only => [ :destroy, :create, :update ],				 :redirect_to => { :action => :list }

	def list
		@healer_skills = HealerSkill.get_page(params[:page])
	end

	def show
		@healer_skill = HealerSkill.find(params[:id])
	end

	def new
		@healer_skill = HealerSkill.new
		@diseases = Disease.find(:all)
	end

	def create
		@healer_skill = HealerSkill.new(params[:healer_skill])
		@diseases = Disease.find(:all)
		if @healer_skill.save
			flash[:notice] = 'HealerSkill was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@healer_skill = HealerSkill.find(params[:id])
		@diseases = Disease.find(:all)
	end

	def update
		@healer_skill = HealerSkill.find(params[:id])
		@diseases = Disease.find(:all)
		if @healer_skill.update_attributes(params[:healer_skill])
			flash[:notice] = 'HealerSkill was successfully updated.'
			redirect_to :action => 'show', :id => @healer_skill
		else
			render :action => 'edit'
		end
	end

	def destroy
		HealerSkill.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
end
