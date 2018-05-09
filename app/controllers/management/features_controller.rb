class Management::FeaturesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :setup_king_pc_vars
  before_filter :set_images, only: [:new, :create, :edit, :update]


  layout 'main'

  def index
    #design features
    @features = Feature.get_page(params[:page], current_player.id, session[:kingdom][:id])
  end

  def show
    @feature = Feature.find(params[:id])
    @feature_events = @feature.feature_events
  end
  
  def new
    @feature = Feature.new
    @image = Image.new
  end
  
  def create
    @feature = Feature.new(feature_params.merge(player_id: current_player.id, kingdom_id: session[:kingdom][:id]))
    @image = @feature.image || Image.new(image_params.merge(player_id: current_player.id, kingdom_id: session[:kingdom][:id]))

    @feature.image_id = 0 unless @feature.image
    calc_feature_cost
    @feature.cost = @cost
    
    if @feature.valid?
      if params[:feature][:image_id].nil? || params[:feature][:image_id] == ""
        @image.resize_image(10,15)
        @image.name ||= "Feature #{@feature.name}"
        @image.save! 
        @feature.image_id = @image.id
      end
      @feature.save
      
      flash[:notice] = @feature.name + ' was sucessfully created.'
      redirect_to :action => 'index'
    else
      flash[:notice] = 'Feature was not created.'
      render :action => 'new'
    end
  end
  
  def edit
    @feature = Feature.find(params[:id])
    @image = @feature.image
    if !is_feature_owner || !is_feature_not_in_use
      redirect_to :action => 'index'
      return
    end
  end
  
  def update
    edit

    @image.update_image(params[:image][:image_text],10,15) unless params[:image][:image_text] == ""
    @image.name = "Feature #{@feature.name}" unless @image.name.present?
    params[:feature][:image_id] = @image.id unless params[:feature].try(:[],:image_id).present?
    
    if @feature.update_attributes(feature_params) & @image.save
      calc_feature_cost
      @feature.cost = @cost
      @feature.save
      flash[:notice] = @feature.name + ' sucessfully updated.'
      redirect_to :action => 'show', :id => params[:id]
    else
      flash[:notice] = @feature.name + ' failed to updated.'
      render :action => 'edit'
    end
  end

  # TODO: this feature_event stuff should be their own resource under feature
  def new_feature_event
    @feature = Feature.find(params[:id])
    @feature_event = FeatureEvent.new
    @events = session[:kingdom].pref_list_events.reload.collect{|pf| pf.event}
  end
  
  def create_feature_event
    @feature = Feature.find(params[:id])
    @feature_event = FeatureEvent.new(feature_event_params.merge(feature_id: params[:id]))
    @events = session[:kingdom].pref_list_events.reload.collect{|pf| pf.event}
    
    if !good_event || !is_feature_owner
      redirect_to :action => 'new_feature_event', :id => params[:id]
      return
    end
    
    if @feature_event.save
      flash[:notice] = 'Feature event created.'
      update_feature_cost
    else
      flash[:notice] = 'Feature event failed to be created.'
      render :action => 'new_feature_event'
    end
  end
  
  def edit_feature_event
    @feature_event = FeatureEvent.find(params[:id])
    @feature = @feature_event.feature
    @events = session[:kingdom].pref_list_events.reload.collect{|pf| pf.event}
  end
  
  def update_feature_event
    @feature_event = FeatureEvent.find(params[:id])
    @feature = @feature_event.feature
    
    if !is_feature_owner || !is_feature_not_in_use
      redirect_to :action => 'index'
      return
    end
    if !good_event
      redirect_to :action => 'edit_feature_event', :id => @feature.id
      return
    end
    
    @events = session[:kingdom].pref_list_events.reload.collect{|pf| pf.event}
    if @feature_event.update_attributes(feature_event_params)
      flash[:notice] = 'Feature event updated.'
      update_feature_cost
    else
      flash[:notice] = 'Feature event failed to update.'
      render :action => 'edit_feature_event'
    end
  end
  
  def destroy_feature_event
    @feature_event = FeatureEvent.find(params[:id])
    @feature = Feature.find(@feature_event.feature_id)
    
    if !is_feature_owner || !is_feature_not_in_use
      redirect_to :action => 'index'
      return
    end
    
    @feature_event.destroy
    flash[:notice] = 'Feature event destroyed.'

    #update feature cost
    @feature = @feature_event.feature
    calc_feature_cost
    @feature.cost = @cost
    if @feature.save
      flash[:notice] += '<br />Feature cost updated.'
    else
      flash[:notice] += '<br />Feature cost failed to update.'
    end
    redirect_to :action => 'show', :id => @feature.id
  end
  
  def arm
    @feature = Feature.find(params[:id])
    if !is_feature_owner
      redirect_to :action => 'index'
      return
    end

    #create the peasant feature encounters if applicable
    #must have the peasant creature and event in the database or this will fail
    flash[:notice] = ''
    @peasant = Creature.find_by(name: 'Peasant')
    if @peasant.nil?
      flash[:notice] += 'The Peasants haven\'t been created yet!<br/>'
    elsif !@feature.num_occupants.nil? && @feature.num_occupants > 0
      if !create_peasant_feature_event(@feature)
        flash[:notice] = 'Failed to make the peasant feature event.'
      end
    end
    
    if @feature.update_attribute(:armed, true)
      flash[:notice] += @feature.name + ' sucessfully armed.'
      #add it to the pref list
      if !@feature.world_feature
        if PrefListFeature.add(session[:kingdom][:id],@feature.id)
          session[:kingdom].pref_list_features.reload
          flash[:notice]+= '<br/>Added to preference list'
        else
          flash[:notice]+= '<br/>Could not be added to preference list'
        end
      end
    else
      flash[:notice] += @feature.name + ' could not be armed.'
    end

    redirect_to :action => 'index', :page => params[:page]
  end
  
  def destroy
    @feature = Feature.find(params[:id])
    if !is_feature_owner || !is_feature_not_in_use
      redirect_to :action => 'index'
      return
    end
    
    for feature_event in @feature.feature_events
      feature_event.destroy
    end
    
    if @feature.destroy
      flash[:notice] = 'Feature destroyed.'
    else
      flash[:notice] = 'Feature was not destroyed.'
    end
    redirect_to :action => 'index', :page => params[:page]
  end
  
  def pref_lists
    session[:pref_list_type] = PrefListFeature
    
    redirect_to :controller => '/management/pref_list'
  end

protected
  def good_event
    if Event.where(armed: true, id: params[:feature_event][:event_id]).find_by(['kingdom_id = ? or player_id  = ?', session[:kingdom][:id], current_player.id])
      return true
    else
      flash[:notice] = "You can't use that event"
      return false
    end
  end


  def calc_feature_cost
    if @feature.num_occupants.nil?
      @feature.num_occupants = 0
    end
    if @feature.store_front_size.nil?
      @feature.store_front_size = 0
    end
  
    #can be expensive computatinally.
    @fees = @feature.feature_events.includes(:event)
    @cost = 500  #base cost of any feature
    
    if @feature.store_front_size > 0
      @cost += ((@feature.store_front_size)**(@feature.store_front_size)) * 10
    end
      
    if @fees.nil? || @fees.size == 0
      @cost += @feature.num_occupants * 100
    else
      @cost += @feature.num_occupants * 500
      @L1 = SpecialCode.get_code('event_rep_type','limited')
      @L2 = SpecialCode.get_code('event_rep_type','limited_per_char')
      
      for fee in @fees
        if fee.event.event_rep_type == @L1
          @cost += fee.event.cost * (fee.chance / 100.0)
        elsif fee.event.event_rep_type == @L2
          @cost += fee.event.cost * (fee.chance / 50.0)
        else
          @cost += fee.event.cost
        end
      end
    end
  end

  def update_feature_cost
    #update feature cost
    @feature = @feature_event.feature
    calc_feature_cost
    @feature.cost = @cost
    if @feature.save
      flash[:notice] += '<br />Feature cost updated.'
      redirect_to :action => 'show', :id => @feature.id
    else
      flash[:notice] += '<br />Feature cost failed to update.'
      render :action => 'new_feature_event'  
    end
  end
  
  def is_feature_owner
    #if someone tries to edit a feature not belonging to them
    if @feature.player_id != current_player.id &&
       @feature.kingdom_id != session[:kingdom][:id]
      flash[:notice] = 'An error occured while retrieving ' + @feature.name
      false
    else
      true
    end
  end

  def is_feature_not_in_use
    if @feature.armed
      flash[:notice] = @feature.name + ' cannot be edited; it is already being used.'
      false
    else
      true
    end
  end
  
  def setup_events_array
    @events = session[:kingdom].pref_list_events.reload.collect{|pf| pf.event}
  end

  def feature_params
    params.require(:feature).permit(
        :name,
        :action_cost,
        :image_id,
        # :player_id,:kingdom_id,
        # :cost,
        :num_occupants,
        :world_feature,
        # :armed,
        :description,
        :store_front_size,
        # :image_text,
        :public
    )
  end

  def feature_event_params
    params.require(:feature_event).permit(
        :chance,
        :event_id,
        :priority,
        :choice
    )
  end

  def image_params
    params.require(:image).permit(
        :image_text,
        :public,
        :picture,
        :image_type
    )
  end

  def set_images
    @images = Image.where(
        ['(public = true or player_id = ? or kingdom_id = ?) and image_type = ?',
         @player_id, @kingdom_id, SpecialCode.get_code('image_type', 'creature')]).order(:name)
  end
end
