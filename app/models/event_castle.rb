class EventCastle < EventLifeNeutral
	def make_happen(who)
		return {:controller => 'game/court', :action => 'castle'}, nil, ""
	end
	
	def as_option_text(pc=nil)
		"Castle offices"
	end
end
