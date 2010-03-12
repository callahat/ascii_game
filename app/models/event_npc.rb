class EventNpc < Event
	belongs_to :npc, :foreign_key => 'thing_id'
	belongs_to :level_map, :foreign_key => 'flex'

	validates_presence_of :thing_id,:flex
	
	def make_happen(who)
		return {:controller => 'game/npc', :action => 'npc'}, nil, ""
	end
end
