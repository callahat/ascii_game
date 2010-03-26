class EventCreature < Event
	belongs_to :creature, :foreign_key => 'thing_id'

	validates_presence_of :thing_id,:flex
	
	def price
		(creature.gold + (creature.experience / (creature.number_alive + 5))) * (high - low - 1)
	end
	
	def make_happen(who)
		low, high = flex.split(";")
		result, msg = Battle.new_creature_battle(who, self.creature, low.to_i, high.to_i, who.present_kingdom)
		if result
			return {:controller => 'game/battle', :action => 'battle'}, EVENT_INPROGRESS, "message seen anywhere for the creature event?"
		else
			return nil, EVENT_COMPLETED, msg
		end
	end

	def validate
		low, high = flex.split(";").collect{|c| c.to_i}
		if !low.nil? && !high.nil? && (low > high)
			errors.add(" ", " low must be less than or equal to high.")
		end
		if low.nil? || low < 1 || low > 500
			errors.add(" ", " low must be between 1 and 500.")
		end
		if high.nil? || high < 1 || high > 500
			errors.add(" ", " high must be between 1 and 500.")
		end
	end
	
	def as_option_text(pc=nil)
		"Fight some " + creature.name.pluralize
	end
end
