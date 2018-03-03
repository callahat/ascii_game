class LogQuestKillSNpc < LogQuestReq
  belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestKillSNpc'
  belongs_to :npc, :foreign_key => 'detail'
  
  def self.complete_req(pcid,npcid)
    @lq = LogQuestKillSNpc.where(owner_id: pcid, detail: npcid)
    
    for lq in @lq
      lq.destroy
    end
  end
  
  def to_sentence
    "Kill " + self.npc.name + (self.npc.kingdom ? " of " + self.npc.kingdom.name : "" ) + "."
  end
end
