class EventMoveRelative < EventLifeNeutral
	validates_presence_of :flex
	
	def make_happen(who)
		PlayerCharacter.transaction do
			who.lock!
			if who.in_kingdom
				@next_level = Level.find(:first, :conditions => ['kingdom_id = ? and level = ?', who.in_kingdom, who.present_level.level + self.flex.to_i])
				if @next_level.nil?
					@message = "The passage is maked \"UNDER CONSTRUCTION\", and comlpetely sealed off"
				else
					who.kingdom_level = @next_level.id
					@message = "Moved to level " + @next_level.level.to_s
				end
			else
				@message = "You're in the world"
			end
			who.save!
		end
		return {:action => 'complete'}, true, @message
	end
	
	def as_option_text(pc=nil)
		"Go to level " + level.level.to_s
	end
end
