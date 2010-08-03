class EventNpc < EventLifeNeutral
	belongs_to :npc, :foreign_key => 'thing_id'
	belongs_to :level_map, :foreign_key => 'flex'

	validates_presence_of :thing_id,:flex
	
	def make_happen(who)
		return {:controller => 'game/npc', :action => 'npc'},EVENT_COMPLETED, ""
	end
	
	def as_option_text(pc=nil)
		if npc.health.wellness == SpecialCode.get_code('wellness','dead')
			"Poke " + npc.name + "'s corpse"
		else
			"Chat with " + npc.name
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
