class EventCastle < EventLifeNeutral
  def make_happen(who)
    return {:controller => 'game/court', :action => 'castle'}, EVENT_COMPLETED, ""
  end
  
  def as_option_text(pc=nil)
    "Castle offices"
  end
end
