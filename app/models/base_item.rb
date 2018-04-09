class BaseItem < ActiveRecord::Base
  has_many :items
  has_one :blacksmith_skill

  has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatBaseItem'

  validates_uniqueness_of :name
  validates_presence_of :name,:price,:equip_loc

  #attr_accessible :name, :description, :equip_loc, :price, :race_body_type
  
  #Pagination related stuff
  def self.get_page(page)
    order('equip_loc,name').paginate(:per_page => 30, :page => page)
  end
end
