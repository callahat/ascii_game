class QuestKillNNpc < QuestReq
  #belongs_to :kingdom

  has_many :log_quest_kill_n_npcs

  validates_presence_of :quest_id,:quantity,:detail
  validates_inclusion_of :quantity, :in => 1..100000, :message => ' must be between 1 and 100000.'

  def kingdom_id
    detail.try(:split, ':').try(:last)
  end

  def npc_division
    detail.try(:split, ':').try(:first)
  end

  def to_sentence
    division = SpecialCode.get_text('npc_division', self.detail.split(":")[0].to_i )
    kingdom = Kingdom.exists?(self.detail.split(":")[1]) && Kingdom.find(self.detail.split(":")[1]).name
    location = " of " + kingdom if kingdom
    "Kill #{quantity} #{division.try(:pluralize, quantity)} #{location}"
  end
end
