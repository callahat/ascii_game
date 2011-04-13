class NpcDisease < Illness
  belongs_to :npc, :foreign_key => 'owner_id', :class_name => 'Npc'
end
