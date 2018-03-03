class QuestExplore < QuestReq
  belongs_to :event, :foreign_key => 'detail'
  belongs_to :objective, :foreign_key => 'detail', :class_name => 'Event'

  has_many :log_quest_explores
  
  validates_presence_of :quest_id,:detail
  
  def to_sentence
    "Journey to " + self.event.name
  end
end
