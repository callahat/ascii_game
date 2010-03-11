class EventStormGate < Event
	belongs_to :level, :foreign_key => 'thing_id'
	
	validates_presence_of :thing_id
	
	def happens(who)
		low, high = flex.split(";")
		result, msg = Battle.storm_gates(who, self.level.kingdom)
		if result
			session[:storm_level] = self.thing_id
			session[:storm_gate] = self.level.kingdom_id
			return {:controller => 'game/battle', :action => 'battle'}, "message seen anywhere for the storm gate event?"
		else
			return true, msg
		end
	end
end
