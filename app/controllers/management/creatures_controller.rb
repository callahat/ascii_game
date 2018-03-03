class Management::CreaturesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter

  layout 'main'

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :index }


  #**********************************************************************
  #CREATURE MANAGEMENT
  #**********************************************************************
  def index
    #design creatures
    @creatures = Creature.get_page(params[:page], session[:player][:id], session[:kingdom][:id])
  end

  def new
    @creature = Creature.new(params[:creature])
    @stat = StatCreature.new(params[:stat])
    @kingdom_id = session[:kingdom][:id]
    @player_id = session[:player][:id]
    @image = @creature.image || Image.new(params[:image])
    @images = Image.where(
                ['(public = true or player_id = ? or kingdom_id = ?) and image_type = ?',
                @player_id, @kingdom_id, SpecialCode.get_code('image_type', 'creature')]).order(:name)
  end

  def create
    new
    @creature.image_id = 0 unless @creature.image
    @image.name = @creature.name + ' image'

    exp = Creature.exp_worth(@stat.dam,@stat.dfn,@creature.HP,@creature.fecundity)
    exp = 0 if exp.nil?

    @creature.experience = exp

    if @stat.valid? && @creature.valid?
      if params[:creature][:image_id].nil? || params[:creature][:image_id] == ""
        @image.save!
        @creature.image_id = @image.id
      end

      @creature.save
      @stat.owner_id = @creature.id
      @stat.save

      flash[:notice] = @creature.name + ' was successfully created.'
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
    @image = @creature.image
    if !verify_creature_owner || !verify_creature_not_in_use
      redirect_to :action => 'index'
      return
    end
    @kingdom_id = session[:kingdom][:id]
    @player_id = session[:player][:id]
    @images = Image.find(
                ['(public = true or player_id = ? or kingdom_id = ?) and image_type = ?',
                @player_id,@kingdom_id,SpecialCode.get_code('image_type', 'creature')]).order(:name)
  end

  def update
    edit
    @image.update_image(params[:image][:image_text]) unless params[:image][:image_text] == ""

    exp = Creature.exp_worth(params[:stat][:dam].to_i,
                             params[:stat][:dfn].to_i,
                             params[:creature][:HP].to_i,
                             params[:creature][:fecundity].to_i)
    exp = 0 if exp.nil?

    params[:creature][:experience] = exp

    if @stat.update_attributes(params[:stat]) & @creature.update_attributes(params[:creature]) & @image.save
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

    if @stat.destroy && @creature.destroy
      flash[:notice] = 'Creature destroyed.'
    else
      flash[:notice] = 'Creature was not destroyed.'
    end
    redirect_to :action => 'index', :page => params[:page]
  end

  def arm_creature
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
