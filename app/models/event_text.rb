class EventText < Event

  def make_happen(ig=nil)
    return nil, EVENT_COMPLETED, text
  end
  
  def as_option_text(pc=nil)
    name + " (text event)"
  end
end
