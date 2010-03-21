class EventMoveWorld < EventLifeNeutral
	#belongs_to :world, :foreign_key => 'thing_id', :class_name => 'World'
	
	def make_happen(who)
		PlayerCharacter.transaction do
			who.lock!
			who.in_kingdom = nil
			who.kingdom_level = nil
			@message = "Left the kingdom"
			who.save!
		end
		return {:action => 'complete'}, EVENT_COMPLETED, @message
	end
	
	def as_option_text(pc=nil)
		"Journey onward into the wilderness"
	end
end
