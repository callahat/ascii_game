class BattlePc < BattleEnemy
	belongs_to :pc, :foreign_key => "enemy_id", :class_name => "PlayerCharacter"
	belongs_to :enemy, :foreign_key => "enemy_id", :class_name => "PlayerCharacter"
	
	has_one :stat, :through => :pc
	has_one :health, :through => :pc
	has_many :illnesses, :through => :pc
	
	def exp_worth
		self.pc.experience / 50
	end
end
