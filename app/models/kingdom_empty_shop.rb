class KingdomEmptyShop < ActiveRecord::Base
  belongs_to :kingdom
  belongs_to :level_map
  
  validates_presence_of :kingdom_id,:level_map_id
end
