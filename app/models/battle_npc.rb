class BattleNpc < BattleEnemy
	belongs_to :npc, :foreign_key => "enemy_id"
	belongs_to :enemy, :foreign_key => "enemy_id", :class_name => "Npc"
	
	has_one :stat, :through => :npc
	has_one :health, :through => :npc
	has_many :illnesses, :through => :npc
	
	def exp_worth
		self.npc.experience / 10
	end
end