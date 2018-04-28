class EventPlayerCharacter < EventLifeNeutral
  belongs_to :player_character, :foreign_key => 'thing_id'
  belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'PlayerCharacter'

  validates_presence_of :thing_id
  
  def make_happen(ig=nil)
    pc = self.player_character
    if pc.health.HP > 0 && pc.health.wellness != SpecialCode.get_code('wellness','dead')
      return nil, EVENT_COMPLETED, ""
    else
      return url_helpers.complete_game_path, EVENT_COMPLETED, pc.name + " has shuffled from this mortal coil"
    end
  end
  
  def as_option_text(pc=nil)
    if thing.health.wellness != SpecialCode.get_code('wellness','dead')
      "Look at " + thing.name + "'s corpse"
    else
      "Chat with " + thing.name
    end
  end
end
