class EventSpawnKingdom < Event
	def make_happen(who)
		if @msg = Kingdom.cannot_spawn(who)
			return {:controller => 'game', :action => 'complete'}, EVENT_COMPLETED, @msg
		else
			return {:controller => 'game', :action => 'spawn_kingdom'}, EVENT_COMPLETED, ""
		end
	end
	
	def as_option_text(pc=nil)
		"Found a new kingdom"
	end
end
