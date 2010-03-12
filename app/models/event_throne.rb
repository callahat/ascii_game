class EventThrone < EventLifeNeutral
	def make_happen(who)
		@king = who.present_kingdom.player_character
		if @king && @king.health.HP > 0 && @king.health.wellness != SpecialCode.get_code('wellness','dead')
			return {:controller => 'game/court', :action => 'throne'}, true, ""
		else
			return {:controller => 'game/court', :action => 'throne'}, nil, ""
		end
	end
end