class LogQuestCreatureKill < LogQuestReq
  belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestCreatureKill'
  belongs_to :creature,  :foreign_key => 'detail'
  belongs_to :objective, :foreign_key => 'detail', :class_name => 'Creature'

  def self.complete_req(pcid,cid,kills=1)
    @lq = LogQuestCreatureKill.where(owner_id: pcid, detail: cid)
    
    #shouldn't need to wrap this in a transaction
    for lq in @lq
      lq.quantity -= kills
      if lq.quantity < 1
        lq.destroy
      else
        lq.save
      end
    end
  end
  
  def to_sentence
    cname = self.objective.name
    "Kill " + self.quantity.to_s + " more " + cname.pluralize(quantity) + "."
  end
end
