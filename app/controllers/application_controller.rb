# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # replace with devise' authenticate method
  alias :authenticate :authenticate_player!

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password


  layout 'main'
  
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
      redirect_to choose_character_character_index_url
      false
    end
  end

  def setup_king_pc_vars
    return(false) unless authenticate
    if @pc = session[:kingdom].player_character
      true
    else
      redirect_to choose_character_character_index_url
      false
    end
  end

  #the admin filter
  def is_admin
    if authenticate_player!
      if current_player.admin
        return true
      else
        redirect_to root_path
        return false
      end
    end
  end
  
  #Checks that the player is a king
  def is_king
    if authenticate_player!
      if current_player.player_characters.where(char_stat: SpecialCode.get_code('char_stat','active')).joins(:kingdoms).any?
        session[:kingbit] = true
        return true
      else
        session[:kingbit] = false
        return false
      end
    end
  end
  
  def king_filter
    if !is_king
      redirect_to game_main_path
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
    @event = EventCreature.new
    @event.kingdom_id = -1
    @event.player_id = -1
    @event.event_rep_type = SpecialCode.get_code('event_rep_type','unlimited')
    @event.name = "\nSYSTEM GENERATED"     #name to anounce this event was generated by the system
    @event.armed = true
    @event.cost = 0

    @event.creature = Creature.find_by(name: "Peasant")
    @event.flex = "1;#{feature.num_occupants}"
    
    if @event.save
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

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) <<  [:handle,
                                                  :password]
    devise_parameter_sanitizer.for(:sign_up) << [:handle,
                                                 :email,
                                                 :password,
                                                 :password_confirmation,
                                                 :city,
                                                 :state,
                                                 :country,
                                                 :bio]

    devise_parameter_sanitizer.for(:account_update) << [:email,
                                                        :password,
                                                        :password_confirmation,
                                                        :current_password,
                                                        :city,
                                                        :state,
                                                        :country,
                                                        :bio]
  end
end
