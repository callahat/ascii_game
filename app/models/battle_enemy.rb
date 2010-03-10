class BattleEnemy < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :battle
	belongs_to :battle_group
	
	def award_exp(amount)
		self.enemy.award_exp(amount)
	end
end
