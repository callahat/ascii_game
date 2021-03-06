class LogQuestKillNNpc < LogQuestReq
  belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestKillNNpc'
  
  def self.complete_req(pcid,npcd,kid,kills=1)
    @lq = LogQuestKillNNpc.where(owner_id: pcid).where(['detail = ? or detail = ?', npcd.to_s + ":" + kid.to_s, ":" + kid.to_s ])

    #shouldn't need to wrap this in a transaction
    for lq in @lq
      lq.quantity -= kills
      ( lq.quantity < 1 ? lq.destroy : lq.save )
    end
  end
  
  def to_sentence
    division = SpecialCode.get_text('npc_division', self.detail.split(":")[0].to_i )
    kingdom = Kingdom.exists?(self.detail.split(":")[1]) && Kingdom.find(self.detail.split(":")[1]).name
    location = " of " + kingdom if kingdom
    "Kill " + self.quantity.to_s + " more " + ( self.quantity > 1 ? division.pluralize : division ) + location + "."
  end
end
