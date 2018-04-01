class Admin::CreaturesController < ApplicationController
  before_filter :authenticate
  before_filter :is_admin

  layout 'admin'

  def index
    @creatures = Creature.get_page(params[:page])
  end

  def new
    @creature = Creature.new
    @creature.build_image
    @creature.build_stat
    @diseases = Disease.all
  end

  def create
    @creature = Creature.new(params[:creature])
    @diseases = Disease.all

    @creature.image.name = @creature.name + ' image'
    @creature.image.player_id = session[:player].id
    @creature.image.kingdom_id = Kingdom.find_by(name: 'SystemGeneratd').id

    @creature.kingdom_id = -1
    @creature.player_id = -1

    if @creature.save
      flash[:notice] = @creature.name + ' was successfully created.'
      redirect_to admin_creature_path(@creature)
    else
      render :action => 'new'
    end
  end

  def show
    @creature = Creature.find(params[:id])
  end

  def edit
    @creature = Creature.find(params[:id])
    @diseases = Disease.all
  end

  def update
    edit

    if @creature.update_attributes(params[:creature])
      flash[:notice] = @creature.name + ' was successfully updated.'
      redirect_to admin_creature_path(@creature)
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

    if !@creature.armed and @creature.destroy
      flash[:notice] = 'Creature destroyed.'
    else
      flash[:notice] = 'Creature was not destroyed.'
    end
    redirect_to admin_creatures_path(page: params[:page])
  end

  def arm
    @creature = Creature.find(params[:id])
    
    if @creature.update_attribute(:armed, true)
      flash[:notice] = @creature.name + ' sucessfully armed.'
      #add it to the pref list
      # if PrefList.add(session[:kingdom][:id],'creatures',@creature.id)
      #   flash[:notice]+= '<br/>Added to preference list'
      # else
      #   flash[:notice]+= '<br/>Could not be added to preference list'
      # end
    else
      flash[:notice] = @creature.name + ' could not be armed.'
    end

    redirect_to admin_creatures_path(page: params[:page])
  end

  #probably dont need this in the admin controller
  # def pref_lists
  #   session[:pref_list_type] = :creature
  #
  #   redirect_to :controller => '/admin/pref_list'
  # end
end
