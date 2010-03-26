class EventStat < Event
	has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatEventStat'
	has_one :health, :foreign_key => 'owner_id', :class_name => 'HealthEventStat'

	def price
		stat.abs_sum_points + health.HP.abs + health.MP.abs
	end
	
	def make_happen(who)
		gold,exp = flex.split(";").collect{|c| c.to_i}
		PlayerCharacter.transaction do
			who.lock!
			who.gold += gold
			who.experience += exp
			who.save!
		end
		Health.transaction do
			who.health.lock!
			who.health.HP += self.health.HP
			who.health.MP += self.health.MP
			who.health.wellness = SpecialCode.get_code('wellness','dead') if @health.HP <= 0
			who.health.save!
		end
		StatPc.transaction do
			who.stat.lock!
			who.stat.add_stats(self.stat)
			who.stat.save!
		end
		return nil, EVENT_COMPLETED, self.text
	end
	
	def as_option_text(pc=nil)
		return text if text
		name + " (status changer)"
	end
end