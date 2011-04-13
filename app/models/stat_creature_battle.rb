class StatCreatureBattle < Stat
  belongs_to :creature, :foreign_key => 'owner_id', :class_name => 'BattleCreature'
  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'BattleCreature'
end
