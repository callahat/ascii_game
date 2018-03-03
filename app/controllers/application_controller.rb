# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :system_up
  
  def system_up
    if SystemStatus.status(1) != 1
      print "halt!"
      render :file => "#{Rails.root}/public/9001.html"
      return false
    end
  end
  
  def setup_pc_vars
    return(false) unless authenticate
    if @pc = session[:player_character]
      true
    else
      redirect_to character_url()
      false
    end
  end
  
  def authenticate
    unless @player = session[:player]
      redirect_to login_url()
      false
    else
      is_king
      true
    end
  end

  #the admin filter
  def is_admin
    if session[:player].nil?
      redirect_to :controller => '/account', :action => 'verify'
    else
      if session[:player].admin
        return true
      else
        redirect_to :controller => '/home'
        return false
      end
    end
  end
  
  #Checks that the player is a king
  def is_king
    # pcs = PlayerCharacter.where(player_id: session[:player][:id], char_stat: SpecialCode.get_code('char_stat','active'))
    # for pc in pcs
    #   if Kingdom.find_by(player_character_id: pc.id)
    #     session[:kingbit] = true
    #     return true
    #   end
    #  end
    # return false
    player = Player.find(session[:player][:id])
    if player.player_characters.where(char_stat: SpecialCode.get_code('char_stat','active')).joins(:kingdoms).any?
      session[:kingbit] = true
      return true
    else
      session[:kingbit] = false
      return false
    end
  end
  
  def king_filter
    if !is_king
      redirect_to :controller => 'game', :action => 'main'
      return false
    else
      return true
    end
  end
  
  #check that the player character selected is the king of the selected kingdom
  def char_is_king
    if session[:player].nil?
      redirect_to :controller => 'account', :action => 'verify'
      return false
    elsif session[:player_character].kingdoms.size == 0
      print "NOT A KING\n"
      redirect_to :controller => 'game', :action => 'main'
      return false
    elsif session[:player_character].nil? || session[:kingdom].nil?
      redirect_to :controller => 'management'
      return false
    elsif session[:player_character].id != session[:kingdom][:player_character_id]
      flash[:notice] = 'Must have the king of the kingdom selected at your current character to do that.'
      redirect_to :controller => '/management' 
      return false
    else
      return true
    end
  end
    
  #Its ok to make all this stuff protected right?
protected
  #def debuggery(crap)
  #  print "\n" + crap.to_s
  #end

  def create_peasant_feature_event(feature)
    #MAKE EVENT  
    @event = Event.new
    @event.kingdom_id = -1
    @event.player_id = -1
    @event.event_rep_type = SpecialCode.get_code('event_rep_type','unlimited')
    @event.name = "\nSYSTEM GENERATED"     #name to anounce this event was generated by the system
    @event.event_type = SpecialCode.get_code('event_type','creature')
    @event.armed = true
    @event.cost = 0
    
    if @event.save
      flash[:notice] = "Created event\n"
    else
      #break code in case event fails to save while developeing this stuff
      flash[:n][:n]
    end
  
    #MAKE SUB EVENT
    @event_creature = EventCreature.new
    @event_creature.event_id = @event.id
    @event_creature.creature_id = Creature.find(:first, :conditions => ['name = ?', "Peasant"]).id
    @event_creature.low = 1
    @event_creature.high = feature.num_occupants
    
    if @event_creature.save
      flash[:notice] += "Created event_npc\n"
    else
      #break code in case event fails to save while developing this stuff
      flash[:n][:n]
    end

    @feature_event = FeatureEvent.new
    
    @feature_event.feature_id = feature.id
    @feature_event.event_id = @event.id
    @feature_event.chance = 65.0
    @feature_event.priority = 42
    @feature_event.choice = true
    
    @feature_event.save
  end
end
