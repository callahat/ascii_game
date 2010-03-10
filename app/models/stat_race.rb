class StatRace < Stat
	belongs_to :race, :foreign_key => 'owner_id'
	belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'Race'
	
	#How many experience points it would require for level
	def total_exp_for_level(l)
		attr = self.dup
		cost = attr.exp_for_level(l)
		cost += attr.race.equip_loc_xp(l)
		cost
	end
end
