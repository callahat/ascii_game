class Admin::CreaturesController < ApplicationController
	before_filter :authenticate
	before_filter :is_admin

	layout 'admin'

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
														:redirect_to => { :action => :index }


	#**********************************************************************
	#CREATURE MANAGEMENT
	#**********************************************************************
	def index
		#design creatures
		@creatures = Creature.get_page(params[:page])
		session[:kingdom][:id] = -1
	end

	def new
		@creature = Creature.new
		@stat = StatCreature.new
		@diseases = Disease.find(:all)
		handle_creature_init_vars
	end

	def create
		handle_creature_init_vars

		@creature = Creature.new(params[:creature])
		@stat = StatCreature.new(params[:stat])
		@diseases = Disease.find(:all)
		exp = Creature.exp_worth(@stat.dam,@stat.dfn,@creature.HP,@creature.fecundity)
		exp = 0 if exp.nil?

		@creature.experience = exp

		handle_creature_image

		if @stat.valid? && @creature.valid?
			@creature.save
			@stat.owner_id = @creature.id
			@stat.save

			flash[:notice] += @creature.name + ' was successfully created.'
			redirect_to :action => 'index'
		else
			render :action => 'new'
		end
	end

	def show
		@creature = Creature.find(params[:id])
	end

	def edit
		@creature = Creature.find(params[:id])
		@stat = @creature.stat
		@diseases = Disease.find(:all)
		@image = @creature.image

		handle_creature_init_vars
	end

	def update
		@creature = Creature.find(params[:id])
		@diseases = Disease.find(:all)
		@stat = @creature.stat
		#@image = @creature.image

		update_creature_image
		handle_creature_init_vars
		
		exp = Creature.exp_worth(params[:stat][:dam].to_i,
														 params[:stat][:dfn].to_i,
														 params[:creature][:HP].to_i,
														 params[:creature][:fecundity].to_i)
		exp = 0 if exp.nil?

		params[:creature][:experience] = exp
		
		if @stat.update_attributes(params[:stat]) & @creature.update_attributes(params[:creature])
			flash[:notice] += @creature.name + ' was successfully updated.'
			redirect_to :action => 'index'
		else
			render :action => 'edit'
		end
	end

	#this will not be used for any creatue that ever graced the world. 
	#Exception is if the user has just created this creature, and nothing is
	#using it. Might want to revisit later, have a write once column for active 
	#things.
	def destroy
		@creature = Creature.find(params[:id])
		@stat = creature.stat
		
		if @stat.destroy && @creature.destroy
			flash[:notice] = 'Creature destroyed.'
		else
			flash[:notice] = 'Creature was not destroyed.'
		end
		redirect_to :action => 'index', :page => params[:page]
	end

	def arm_creature
		@creature = Creature.find(params[:id])
		
		if @creature.update_attribute(:armed, true)
			flash[:notice] = @creature.name + ' sucessfully armed.'
			#add it to the pref list
			if PrefList.add(session[:kingdom][:id],'creatures',@creature.id)
				flash[:notice]+= '<br/>Added to preference list'
			else
				flash[:notice]+= '<br/>Could not be added to preference list'
			end
		else
			flash[:notice] = @creature.name + ' could not be armed.'
		end

		redirect_to :action => 'index', :page => params[:page]
	end

	#probably dont need this in the admin controller
	def pref_lists
		session[:pref_list_type] = :creature
		
		redirect_to :controller => '/admin/pref_list'
	end
end
