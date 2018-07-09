class Management::CastlesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter
  before_filter :init_stairways, only: [:levels, :destroy]
  before_filter :init_throne, only: [:throne, :throne_level, :throne_square, :set_throne]
  before_filter :setup_king_pc_vars

  layout 'main'

  def show
  end

  def levels
  end

  #new staircase (move that can take a player from level 0 to any existing level.
  #Each costs 500, regardless of where it goes.
  def new
    @levels = session[:kingdom].levels
  end

  #create the move
  def create
    #enough moneys?
    @cost = 500
    if @cost > session[:kingdom][:gold]
      flash[:notice] = 'Not enough in treasury to build more stairs'
      redirect_to :action => 'new'
      return
    end

    #Take the moneys
    session[:kingdom][:gold] -= 500
    session[:kingdom].save

    @levels = session[:kingdom].levels
    @level = Level.find(params[:level][:id])
    @feature = Feature.find_by(name: "Castle #{session[:kingdom].name}", system_generated: true)

    build_stairway(@level,@feature)

    flash[:notice] = 'Built stairway. ' + session[:kingdom][:gold].to_s + ' gold left.'

    redirect_to :action => 'levels'
  end

  def destroy
    #destroy the stair. no money back though.
    @event = @stairways.find(params[:id])

    @event.feature_events.destroy_all
    @event.destroy!

    flash[:notice] = "Stairway to level #{@event.level.level} destroyed"

    redirect_to :action => 'levels'
  end

  def throne
  end

  def throne_level
    @levels = session[:kingdom].levels
    render :action => 'throne'
  end

  def throne_square
    session[:level_id] ||= params[:level][:id]
    @squares = session[:kingdom].levels.find(session[:level_id])
    render :action => 'throne'
  end

  def set_throne
    #delete the old throne by setting that the old square to nil (unless this is the first set_throne)
    @level_map = LevelMap.find(params[:throne][:spot])
    unless @level_map.feature.try(:valid_throne_location)
      flash[:notice] = "Invalid place for throne; something else is already there"
      throne_square
      return
    end
    @level = @level_map.level
    if @throne.nil?
      #This assumes that the throne event was created when the kingom itself was created!
      @throne_event = Event.find_by(name: "Throne #{session[:kingdom].name} event", system_generated: true)
      @old_fe = Feature.where(name: "Castle #{session[:kingdom].name}", system_generated: true).last.feature_events.where(event_id: @throne_event).last
      if !@old_fe.nil?
        @old_fe.destroy
      end

      #TAKE CARE OF IMAGE HERE
      @image = Image.find_by(name: 'DEFAULT THRONE')
      @new_image = Image.deep_copy(@image)
      @new_image.kingdom_id = session[:kingdom][:id]
      @new_image.name = "Throne Image"
      @new_image.save
      #/ IMAGE SETUP CODE

      #However, assume the throne feature not set up yet.
      @throne = Feature.sys_gen("Throne #{session[:kingdom].name}", @new_image.id)

      if !@throne.save
        Rails.logger.error 'Failed to save throne.'
        Rails.logger.error @throne.errors
      end

      throne_feature_event(@throne,@throne_event)
    else
      @emtpy_feature = Feature.find_by(name: "Empty", kingdom_id: -1, player_id: -1)

      @old_level_map = @throne.level_maps.last
      @old_level = @old_level_map.level

      #Overwrite old feature to empty
      @temp = LevelMap.new
      @temp.level_id = @old_level.id
      @temp.xpos = @old_level_map.xpos
      @temp.ypos = @old_level_map.ypos
      @temp.feature = @emtpy_feature
      @temp.save
    end

    #Place the throne
    @temp = LevelMap.new
    @temp.level_id = @level.id
    @temp.xpos = @level_map.xpos
    @temp.ypos = @level_map.ypos
    @temp.feature_id = @throne.id
    @temp.save!

    session[:level_id] = nil
    redirect_to :action => 'throne'
  end

  protected

  def build_stairway(level,feature)
    #MAKE EVENT
    @event = EventMoveLocal.sys_gen({:name => "Standard Stairway",
                                     :event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
                                     :thing_id => level.id } )
    @event.save!
    flash[:notice] = "Created event\n"

    #LINK EVENT TO FEATURE
    @feature_event = FeatureEvent.new
    @feature_event.feature_id = feature.id
    @feature_event.event_id = @event.id
    @feature_event.chance = 100.0
    @feature_event.priority = 42
    @feature_event.choice = true

    @feature_event.save!
    flash[:notice] += "Created feature_event\n"
  end

  #throne event should already exist for kingdom.
  def throne_feature_event(feature,event)
    Rails.logger.info "Creating throne feature event"
    @feature_event = FeatureEvent.new
    Rails.logger.info @feature_event.feature_id = feature.id
    Rails.logger.info ""
    Rails.logger.info @feature_event.event_id = event.id
    Rails.logger.info ""
    Rails.logger.info @feature_event.chance = 100.0
    Rails.logger.info ""
    Rails.logger.info @feature_event.priority = 42
    Rails.logger.info ""
    Rails.logger.info @feature_event.choice = true
    Rails.logger.info ""

    if @feature_event.save
      flash[:notice] = "Created feature_event"
    else
      Rails.logger.info "soemthing went wrong!"
      flash[:n][:n]
    end
  end

  def init_stairways
    @stairways = Feature
        .where(['name = ? and system_generated = true', "Castle #{session[:kingdom].name}"])
        .first
        .try(:local_move_events) || []
  end

  def init_throne
    @throne = Feature.find_by(name: "Throne #{session[:kingdom].name}", system_generated: true)
  end
end
