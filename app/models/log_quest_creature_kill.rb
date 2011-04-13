class LogQuestCreatureKill < LogQuestReq
  belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestCreatureKill'
  belongs_to :creature, :foreign_key => 'detail'
  
  def self.complete_req(pcid,cid,kills=1)
    @lq = LogQuestCreatureKill.find(:all, :conditions => ['owner_id = ? AND detail = ?', pcid, cid])
    
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
    cname = self.creature.name
    "Kill " + self.quantity.to_s + " more " + (self.quantity > 1 ? cname.pluralize : cname) + "."
  end
end
