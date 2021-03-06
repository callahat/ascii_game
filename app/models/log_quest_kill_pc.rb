class LogQuestKillPc < LogQuestReq
  belongs_to :quest_req,        :foreign_key => 'quest_req_id', :class_name => 'QuestKillPc'
  belongs_to :player_character, :foreign_key => 'detail'
  belongs_to :objective,        :foreign_key => 'detail', :class_name => 'PlayerCharacter'
  
  def self.complete_req(pcid,kill_pcid)
    @lq = LogQuestKillPc.where(owner_id: pcid, detail: kill_pcid)
    
    for lq in @lq
      lq.destroy
    end
  end
  
  def to_sentence
    pc = self.objective
    "Kill " + pc.name + " of " + Kingdom.find(pc.kingdom_id).name + "."
  end
end
