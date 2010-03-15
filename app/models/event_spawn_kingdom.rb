class EventSpawnKingdom < Event
	def make_happen(who)
		if @msg = Kingdom.cannot_spawn(who)
			return {:controller => '/game', :action => 'complete'}, false, @msg
		else
			return {:controller => '/game', :action => 'spawn_kingdom'}, false, ""
		end
	end
	
	def as_option_text(pc=nil)
		"Found a new kingdom"
	end
end
