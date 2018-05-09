class QuestItem < QuestReq
  belongs_to :item, :foreign_key => 'detail'
  belongs_to :objective, :foreign_key => 'detail', :class_name => 'Item'
  
  validates_presence_of :quest_id,:detail,:quantity
  validates_inclusion_of :quantity,:in => 1..2000, :message => ' must be between 1 and 2000.'
  
  def to_sentence
    "Retrieve #{quantity} #{item.name.pluralize quantity}"
  end
end
