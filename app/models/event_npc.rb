class EventNpc < EventLifeNeutral
	belongs_to :npc, :foreign_key => 'thing_id'
	belongs_to :level_map, :foreign_key => 'flex'

	validates_presence_of :thing_id,:flex
	
	def make_happen(who)
		return {:controller => 'game/npc', :action => 'npc'},EVENT_COMPLETED, ""
	end
	
	def as_option_text(pc=nil)
		if player_chracter.health.wellness != SpecialCode.get_code('wellness','dead')
			"Poke " + npc.name + "'s corpse"
		else
			"Chat with " + npc.name
		end
	end
end
