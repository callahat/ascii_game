class QuestKillPc < QuestReq
  belongs_to :player_character, :foreign_key => 'detail'

  has_many :log_quest_kill_pcs
  
  validates_presence_of :quest_id,:detail
  
  def to_sentence
    pc = self.player_character
    "Kill " + pc.name + " of " + pc.kingdom.name + "."
  end
end
