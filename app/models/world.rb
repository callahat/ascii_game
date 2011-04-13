class World < ActiveRecord::Base
  has_many :kingdoms
  has_many :world_maps
  has_many :event_creatures, :foreign_key => 'thing_id'
  
  #Pagination related stuff
  def self.per_page
    10
  end
  
  def self.get_page(page)
    paginate(:page => page )
  end
end
