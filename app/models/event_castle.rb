class EventCastle < EventLifeNeutral
  def make_happen(who)
    return url_helpers.castle_game_court_path, EVENT_COMPLETED, ""
  end
  
  def as_option_text(pc=nil)
    "Castle offices"
  end
end
