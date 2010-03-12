class EventCastle < EventLifeNeutral
	def make_happen(who)
		return {:controller => 'game/court', :action => 'castle'}, nil, ""
	end
end
