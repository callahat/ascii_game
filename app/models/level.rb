class Level < ActiveRecord::Base
  belongs_to :kingdom

  has_many :level_maps
  has_many :event_creatures, :foreign_key => 'thing_id'
  
  validates_presence_of :level
  validates_inclusion_of :maxx,:in => 1..5, :message => ' must be between 1 and 5.'
  validates_inclusion_of :maxy,:in => 1..5, :message => ' must be between 1 and 5.'

  attr_accessible :maxx, :maxy, :level

  #Pagination related stuff
  def self.get_page(page, kid = nil)
    where(kid ? ['kingdom_id = ?', kid] : []) \
      .order('level') \
      .paginate(:per_page => 10, :page => page)
  end
end
