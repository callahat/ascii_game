class EventSpawnKingdom < Event
	def make_happen(who)
		if @msg = Kingdom.cannot_spawn(who)
			return {:controller => '/game', :action => 'complete'}, false, @msg
		else
			return {:controller => '/general', :action => 'spawn_kingdom'}, false, ""
		end
	end
end
