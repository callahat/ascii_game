class Quest < ActiveRecord::Base
  belongs_to :item
  belongs_to :kingdom
  belongs_to :player
  belongs_to :quest

  has_many :quests
  has_many :done_quests
  has_many :log_quests
  
  has_many :reqs, :class_name => "QuestReq"
  
  has_many :creature_kills, :class_name => "QuestCreatureKill"
  has_many :explores, :class_name => "QuestExplore"
  has_many :items, :class_name => "QuestItem"
  has_many :kill_n_npcs, :class_name => "QuestKillNNpc"
  has_many :kill_pcs, :class_name => "QuestKillPc"
  has_many :kill_s_npcs, :class_name => "QuestKillSNpc"
  
  validates_presence_of :name,:kingdom_id,:player_id,:quest_status
  validates_uniqueness_of :name
  
  validates_inclusion_of :max_level, within: 1..500, allow_nil: true, message: "Must be between 1 and 500"

  validates :max_completeable, :numericality => { :greater_than => 0 }, :allow_nil => true

  #attr_accessible :name, :description, :kingdom_id, :player_id, :max_level, :max_completeable, :quest_status, :gold, :item_id, :quest_id

 def validate
   if quest_id && quest.kingdom_id != kingdom_id
     errors.add("quest_id","invalid prerequisite quest.")
   end
 end
  
  def all_reqs
    return self.reqs
  end
  
  #Pagination related stuff
  def self.get_page(page, kid = nil)
    where(kid ? ['kingdom_id = ?', kid] : []) \
      .order('quest_status,name') \
      .paginate(:per_page => 15, :page => page)
  end
end
