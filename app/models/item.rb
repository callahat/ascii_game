class Item < ActiveRecord::Base
	belongs_to :kingdom
	belongs_to :base_item
	belongs_to :c_class
	belongs_to :race
	belongs_to :npc

	has_many :event_items
	has_many :kingdom_items, :foreign_key => 'owner_id', :class_name => 'KingdomItem'
	has_many :npc_blacksmith_items
	has_many :npc_stocks, :foreign_key => 'owner_id', :class_name => 'NpcStock'
	has_many :player_character_equip_locs
	has_many :player_character_items, :foreign_key => 'owner_id', :class_name => 'PlayerCharacterItem'
	has_many :quests
	has_many :quest_items

	has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatItem'
	
	validates_presence_of :name,:min_level,:base_item_id,:equip_loc
	
	def used_price
		price / 2
	end
	
	def resell_value
		(price / 6.0).ceil
	end
	
	#Pagination related stuff
	def self.per_page
		10
	end
	
	def self.get_page(page)
		paginate(:page => page, :order => 'name' )
	end
end
