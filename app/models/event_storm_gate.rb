class EventStormGate < Event
	belongs_to :level, :foreign_key => 'thing_id'
	
	validates_presence_of :thing_id
	
	def make_happen(who)
		result, msg = Battle.storm_gates(who, self.level.kingdom)
		if result
			return {:controller => 'game/battle', :action => 'battle'}, EVENT_INPROGRESS, "message seen anywhere for the storm gate event?"
		else
			return nil, EVENT_COMPLETED, msg
		end
	end
	
	def completes(who)
		#Player enters castle if sucessfully stormed
		PlayerCharacter.transaction do
			who.lock!
			who.in_kingdom = level.kingdom_id
			who.kingdom_level = thing_id
			who.save!
		end
		KingdomNotice.create_storm_gate_notice(who.name, level.kingdom_id)
	end
	
	def as_option_text(pc=nil)
		"Storm the gates of " + level.kingdom.name
	end
end
