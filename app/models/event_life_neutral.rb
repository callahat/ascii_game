class EventLifeNeutral < Event
  #Call the child function to make the action happen, don't care if who
  #is alive or not
  def happens(who)
    self.make_happen(who)
  end
end
