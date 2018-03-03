class Management::CastlesController < ApplicationController
  before_filter :authenticate
  before_filter :king_filter

  layout 'main'

  def index
    @moves = session[:kingdom].levels.where(level: 0).last
  end

#  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :set_throne ],         :redirect_to => { :action => :index }

  #SHOW moves
  def show
    @moves = Feature.where(['name = ?', "\nCastle #{session[:kingdom].name}"]).first

    if @moves
      @moves = @moves.feature_events.includes(:event).where( ['events.kind = ?', 'EventMoveLocal'] )
    end
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
    @feature = Feature.find_by(name: "\nCastle #{session[:kingdom].name}")

    build_stairway(@level,@feature)

    flash[:notice] = 'Built stairway. ' + session[:kingdom][:gold].to_s + ' gold left.'

    redirect_to :action => 'show'
  end

  def destroy
    #destroy the stair. no money back though.
    @feature_event = Feature.find_by(name: "\nCastle #{session[:kingdom].name}").feature_events.find(params[:id])
    @event = @feature_event.event

    @feature_event.destroy
    @event.destroy

    redirect_to :action => 'show'
  end

  def throne
    @throne = Feature.where(name: "\nThrone #{session[:kingdom].name}").last
  end

  def throne_level
    @levels = session[:kingdom].levels
    render :action => 'throne'
  end

  def throne_square
    @squares = session[:kingdom].levels.find(params[:level][:id])
    @x,@y = 0,0
    if @squares.nil?
      flash[:notice] = 'Invalid level; no squares found.'
      redirect_to :action => 'throne_level'
      return false
    end

    render :action => 'throne'
  end

  def set_throne
    #delete the old throne by setting that the old square to nil (unless this is the first set_throne)
    @throne = Feature.where(name: "\nThrone #{session[:kingdom].name}").last
    @level_map = LevelMap.find(params[:throne][:spot])
    @level = @level_map.level
    if @throne.nil?
      #This assumes that the throne event was created when the kingom itself was created!
      @throne_event = Event.find_by(name: "\nThrone #{session[:kingdom].name} event")
      @old_fe = Feature.where(name: "\nCastle #{session[:kingdom].name}").last.feature_events.where(event_id: @throne_event).last
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
      @throne = Feature.sys_gen("\nThrone #{session[:kingdom].name}", @new_image.id)

      if !@throne.save
        print 'Failed to save throne.'
        print @throne.errors
      end

      throne_feature_event(@throne,@throne_event)
    else
      @old_level_map = @throne.level_maps.last
      @old_level = @old_level_map.level

      #Overwrite old feature to nil
      @temp = LevelMap.new
      @temp.level_id = @old_level.id
      @temp.xpos = @old_level_map.xpos
      @temp.ypos = @old_level_map.ypos
      @temp.feature_id = nil
      @temp.save
    end

    #Place the throne
    @temp = LevelMap.new
    @temp.level_id = @level.id
    @temp.xpos = @level_map.xpos
    @temp.ypos = @level_map.ypos
    @temp.feature_id = @throne.id
    if !@temp.save
      print "\nBollocks"
      params[:f][:f]
    end

    redirect_to :action => 'throne'
  end

protected
  def build_stairway(level,feature)
    #MAKE EVENT
    @event = EventMoveLocal.sys_gen({:name => "\nSYSTEM GENERATED",
                                     :event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
                                     :thing_id => level.id } )
    if @event.save
      flash[:notice] = "Created event\n"
    else
      #break code in case event fails to save while developeing this stuff
      flash[:n][:n]
    end

    #LINK EVENT TO FEATURE
    @feature_event = FeatureEvent.new
    @feature_event.feature_id = feature.id
    @feature_event.event_id = @event.id
    @feature_event.chance = 100.0
    @feature_event.priority = 42
    @feature_event.choice = true

    if @feature_event.save
      flash[:notice] += "Created feature_event\n"
    else
      flash[:n][:n]
    end
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
end
