class Race < ActiveRecord::Base
  belongs_to :kingdom
  belongs_to :image

  has_one :level_zero, :foreign_key => 'owner_id', :class_name => 'StatRace', dependent: :destroy
  has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatRace'

  has_many :player_characters
  has_many :race_equip_locs, dependent: :destroy

  accepts_nested_attributes_for :level_zero
  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :race_equip_locs, reject_if: lambda {|attrs| attrs[:equip_loc].blank? }

  validates_uniqueness_of :name
  validates_presence_of :name,:race_body_type,:freepts,:level_zero,:image,:race_equip_locs

  def equip_loc_xp(l)
    @locs = race_equip_locs.size
    Race.num_equip_loc_xp(@locs) * l
  end
  def self.num_equip_loc_xp(n)
    #up to 10 equip locations with no XP penalty
    (3**(n-11)).floor*10
  end

  def attributes_with_nesteds
    attributes.merge(
        level_zero_attributes: level_zero.attributes.slice(*Stat.symbols.map(&:to_s)),
        race_equip_locs_attributes: race_equip_locs.map{|r| r.attributes.slice('equip_loc')},
        image_attributes: image.attributes.slice('image_text','image_type','picture','name')
    )
  end

  #Pagination related stuff
  def self.get_page(page)
    order('name').paginate(:per_page => 10, :page => page)
  end
end
