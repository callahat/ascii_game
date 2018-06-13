class EventNpc < EventLifeNeutral
  belongs_to :npc, :foreign_key => 'thing_id'
  belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Npc'
  belongs_to :level_map, :foreign_key => 'flex'

  validates_presence_of :thing_id,:flex
  
  def make_happen(who)
    return url_helpers.npc_game_npc_path, EVENT_COMPLETED, ""
  end
  
  def as_option_text(pc=nil)
    if thing.health.wellness == SpecialCode.get_code('wellness','dead')
      "Poke " + thing.name + "'s corpse"
    else
      "Chat with " + thing.name_and_titles
    end
  end
  
  def self.generate(npc_id, lm_id)
    self.sys_gen!(
        :event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
        :name => "\nSYSTEM GENERATED",
        :thing_id => npc_id,
        :flex => lm_id
      )
  end
end
