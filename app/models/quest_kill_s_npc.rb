class QuestKillSNpc < QuestReq
  belongs_to :npc, :foreign_key => 'detail'
  belongs_to :objective, :foreign_key => 'detail', :class_name => 'Npc'

  has_many :log_quest_kill_s_npcs
  
  validates_presence_of :quest_id,:detail
  
  def to_sentence
    "Kill #{npc.name}#{npc.kingdom ? " of #{npc.kingdom.name}" : "" }."
  end
end
