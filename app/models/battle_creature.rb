class BattleCreature < BattleEnemy
  belongs_to :creature, :foreign_key => "enemy_id"
  belongs_to :enemy, :foreign_key => "enemy_id", :class_name => "Creature"
  
  has_one :stat, :foreign_key => "owner_id", :class_name => "StatCreatureBattle"
  has_one :health, :foreign_key => "owner_id", :class_name => "HealthCreatureBattle"
  
  def exp_worth
    creature.experience
  end
  
  def illnesses
    self.creature.disease.to_a
  end
end
