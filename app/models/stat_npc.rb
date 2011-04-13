class StatNpc < Stat
  belongs_to :npc, :foreign_key => 'owner_id'
  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'Npc'
end
