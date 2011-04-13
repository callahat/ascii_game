class QuestKillSNpc < QuestReq
  belongs_to :npc, :foreign_key => 'detail'

  has_many :log_quest_kill_s_npcs
  
  validates_presence_of :quest_id,:detail
  
  def to_sentence
    "Kill " + self.npc.name + (self.npc.kingdom ? " of " + self.npc.kingdom.name : "" ) + "."
  end
end
