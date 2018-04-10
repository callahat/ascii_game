class Item < ActiveRecord::Base
  belongs_to :base_item
  belongs_to :c_class
  belongs_to :race
  belongs_to :npc

  has_many :event_items, :foreign_key => 'thing_id', :class_name => 'EventItem'
  has_many :kingdom_items, :foreign_key => 'owner_id', :class_name => 'KingdomItem'
  has_many :npc_blacksmith_items
  has_many :npc_stocks, :foreign_key => 'owner_id', :class_name => 'NpcStock'
  has_many :player_character_equip_locs
  has_many :player_character_items, :foreign_key => 'owner_id', :class_name => 'PlayerCharacterItem'
  has_many :quests
  has_many :quest_items, :foreign_key => 'detail', :class_name => 'QuestReq'
  has_many :inventories

  has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatItem', dependent: :destroy

  accepts_nested_attributes_for :stat

  validates_presence_of :name,:min_level,:base_item_id,:equip_loc

  def used_price
    price / 2
  end
  
  def resell_value
    (price / 6.0).ceil
  end

  def attributes_with_nesteds
    attributes.merge stat_attributes: stat.attributes.slice(*Stat.symbols.map(&:to_s))
  end

  def in_use?
    [:inventories,
     :player_character_equip_locs,
     :npc_blacksmith_items,
     :event_items,
     :quests,
     :quest_items
    ].each do |dependent|
      return true if send(dependent).count > 0
    end
    false
  end

  #Pagination related stuff
  def self.get_page(page)
    order('name').paginate(:per_page => 10, :page => page)
  end
end
