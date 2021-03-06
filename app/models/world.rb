class World < ActiveRecord::Base
  has_many :kingdoms
  has_many :world_maps
  has_many :event_creatures, :foreign_key => 'thing_id'

  #Pagination related stuff
  def self.get_page(page)
    order('name').paginate(:per_page => 20, :page => page)
  end
end
