class QuestCreatureKill < QuestReq
  belongs_to :creature, :foreign_key => 'detail'
  belongs_to :objective, :foreign_key => 'detail', :class_name => 'Creature'

  has_many :log_quests
  has_many :log_quest_creature_kills
  
  validates_presence_of :quest_id,:detail,:quantity
  validates_inclusion_of :quantity, :in => 1..100000, :message => ' must be between 1 and 100000.'
  
  def to_sentence
    "Kill #{quantity} #{creature.name.pluralize quantity}"
  end
end
