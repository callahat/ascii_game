class StatCreature < Stat
  belongs_to :creature, :foreign_key => 'owner_id'
  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'Creature'
end
