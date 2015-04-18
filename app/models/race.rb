class Race < ActiveRecord::Base
  belongs_to :kingdom
  belongs_to :image

  has_one :level_zero, :foreign_key => 'owner_id', :class_name => 'StatRace'
  has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatRace'

  has_many :player_characters
  has_many :race_equip_locs
  has_many :race_levels

  validates_uniqueness_of :name
  validates_presence_of :name,:race_body_type,:freepts
  
  def equip_loc_xp(l)
    @locs = race_equip_locs.size
    Race.num_equip_loc_xp(@locs) * l
  end
  def self.num_equip_loc_xp(n)
    #up to 10 equip locations with no XP penalty
    (3**(n-11)).floor*10
  end
  
  #Pagination related stuff
  def self.get_page(page)
    order('name').paginate(:per_page => 10, :page => page)
  end
end
