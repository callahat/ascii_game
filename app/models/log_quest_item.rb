class LogQuestItem < LogQuestReq
  belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestItem'
  belongs_to :item, :foreign_key => 'detail'
  
  def complete_req
    return false unless owner_item = owner.items.find(:first, :conditions => ['item_id = ?', detail])
    PlayerCharacterItem.transaction do
      owner_item.lock!
      taken = (self.quantity > owner_item.quantity ? owner_item.quantity : self.quantity)
      self.quantity -= taken
      owner_item.quantity -= taken
      owner_item.save!
    end
    KingdomItem.update_inventory(quest.kingdom_id,detail,taken)
    if quantity < 1
      self.destroy
    else
      self.save
    end
  end
  
  def to_sentence
    iname = self.item.name
    "Retrieve " + self.quantity.to_s + " more " + (self.quantity > 1 ? iname.pluralize : iname) + "."
  end
end
