class EventStormGate < Event
	belongs_to :level, :foreign_key => 'thing_id'
	
	validates_presence_of :thing_id
	
	def make_happen(who)
		result, msg = Battle.storm_gates(who, self.level.kingdom)
		if result
			return {:controller => 'game/battle', :action => 'battle'}, false, "message seen anywhere for the storm gate event?"
		else
			return nil, true, msg
		end
	end
	
	def as_option_text(pc=nil)
		"Storm the gates of " + level.kingdom.name
	end
end
