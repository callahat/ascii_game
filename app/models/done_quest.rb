class DoneQuest < ActiveRecord::Base
  belongs_to :player_character
  belongs_to :quest
  
  #Pagination related stuff
  def self.per_page
    20
  end
  
  def self.get_page(page, pcid = nil)
    joins('INNER JOIN quests on done_quests.quest_id = quests.id') \
      .where(pcid ? ['player_character_id = ?', pcid] : []) \
      .order('"done_quests.date DESC","quests.name"') \
      .paginate(:per_page => 20, :page => page)
  end
end
