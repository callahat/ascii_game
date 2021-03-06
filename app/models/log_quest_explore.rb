class LogQuestExplore < LogQuestReq
  belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestExplore'
  belongs_to :event,     :foreign_key => 'detail'
  belongs_to :objective, :foreign_key => 'detail', :class_name => 'Event'
  
  def self.complete_req(pcid,event_id)
    @lq = LogQuestExplore.where(owner_id: pcid, detail: event_id)
    
    for lq in @lq
      lq.destroy
    end
  end
  
  def to_sentence
    "Journey to " + self.objective.name
  end
end
