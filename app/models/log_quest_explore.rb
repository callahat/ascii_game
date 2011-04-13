class LogQuestExplore < LogQuestReq
  belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestExplore'
  belongs_to :event, :foreign_key => 'detail'
  
  def self.complete_req(pcid,event_id)
    @lq = LogQuestExplore.find(:all, :conditions => ['owner_id = ? AND detail = ?', pcid, event_id])
    
    for lq in @lq
      lq.destroy
    end
  end
  
  def to_sentence
    "Journey to " + self.event.name
  end
end
