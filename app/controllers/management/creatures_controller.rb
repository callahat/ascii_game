class Management::CreaturesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :setup_king_pc_vars

  layout 'main'

  def index
    @creatures = Creature.get_page(params[:page], session[:player][:id], session[:kingdom][:id])
  end

  def new
    @creature = Creature.new(params[:creature])
    @creature.build_stat
    # @kingdom_id = session[:kingdom][:id]
    # @player_id = session[:player][:id]
    @image = @creature.image || @creature.build_image
    @images = Image.where(
                ['(public = true or player_id = ? or kingdom_id = ?) and image_type = ?',
                @player_id, @kingdom_id, SpecialCode.get_code('image_type', 'creature')]).order(:name)
  end

  def create
    if params[:creature][:image_id].present?
      params[:creature][:image_attributes].merge!(
          Image.find(params[:creature][:image_id]).attributes.slice('image_text','picture'))
      params[:creature].delete(:image_id)
    end

    @creature = Creature.new(params[:creature])

    @creature.build_image unless @creature.image
    @creature.image.name = @creature.name.to_s + ' image'
    @creature.image.player_id = session[:player].id
    @creature.image.kingdom_id = session[:kingdom].id

    @creature.player_id = session[:player].id
    @creature.kingdom_id = session[:kingdom].id

    if @creature.save
      flash[:notice] = @creature.name + ' was successfully created.'
      redirect_to management_creature_path(@creature)
    else
      @creature.build_stat
      @image = @creature.image || @creature.build_image
      @images = Image.where(
          ['(public = true or player_id = ? or kingdom_id = ?) and image_type = ?',
           @player_id, @kingdom_id, SpecialCode.get_code('image_type', 'creature')]).order(:name)
      render :action => 'new'
    end
  end

  def show
    @creature = Creature.find(params[:id])
  end

  def edit
    @creature = Creature.find(params[:id])

    if !verify_creature_owner || !verify_creature_not_in_use
      redirect_to :action => 'index'
      return
    end
    @images = Image.where(
                ['(public = true or player_id = ? or kingdom_id = ?) and image_type = ?',
                @player_id,@kingdom_id,SpecialCode.get_code('image_type', 'creature')]).order(:name)
  end

  def update
    edit

    if @creature.update_attributes(params[:creature])
      flash[:notice] = @creature.name + ' was successfully updated.'
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
    @stat = @creature.stat
    if !verify_creature_owner || !verify_creature_not_in_use
      redirect_to :action => 'index'
      return
    end

    if @creature.destroy
      flash[:notice] = 'Creature destroyed.'
    else
      flash[:notice] = 'Creature was not destroyed.'
    end
    redirect_to :action => 'index', :page => params[:page]
  end

  def arm
    @creature = Creature.find(params[:id])
    if !verify_creature_owner
      redirect_to :action => 'index'
      return
    end

    if @creature.update_attribute(:armed, true)
      flash[:notice] = @creature.name + ' sucessfully armed.'
      #add it to the pref list
      if PrefListCreature.add(session[:kingdom][:id],@creature.id)
        flash[:notice]+= '<br/>Added to preference list'
      else
        flash[:notice]+= '<br/>Could not be added to preference list'
      end
    else
      flash[:notice] = @creature.name + ' could not be armed.'
    end

    redirect_to :action => 'index', :page => params[:page]
  end

  def pref_lists
    session[:pref_list_type] = PrefListCreature
    redirect_to :controller => '/management/pref_list'
  end

protected

  def verify_creature_owner
    #if someone tries to edit a creature not belonging to them
    if @creature.player_id != session[:player][:id] &&
       @creature.kingdom_id != session[:kingdom][:id]
      flash[:notice] = 'An error occured while retrieving ' + @creature.name
      false
    else
      true
    end
  end

  def verify_creature_not_in_use
    if @creature.armed
      flash[:notice] = @creature.name + ' cannot be edited; it is already being used.'
      false
    else
      true
    end
  end
end
