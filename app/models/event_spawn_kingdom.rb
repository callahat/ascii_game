class EventSpawnKingdom < Event
  def make_happen(who)
    if @msg = Kingdom.cannot_spawn(who)
      return url_helpers.complete_game_path, EVENT_FAILED, @msg
    else
      return url_helpers.spawn_kingdom_game_path, EVENT_COMPLETED, ""
    end
  end
  
  def as_option_text(pc=nil)
    "Found a new kingdom"
  end
end
