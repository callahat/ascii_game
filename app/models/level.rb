class Level < ActiveRecord::Base
	belongs_to :kingdom

	has_many :level_maps
	
	validates_presence_of :level
	validates_inclusion_of :maxx,:in => 1..5, :message => ' must be between 1 and 5.'
	validates_inclusion_of :maxy,:in => 1..5, :message => ' must be between 1 and 5.'
	
	#Pagination related stuff
	def self.per_page
		10
	end
	
	def self.get_page(page, kid = nil)
		if kid.nil?
		paginate(:page => page, :order => 'level' )
	else
			paginate(:page => page, :conditions => ['kingdom_id = ?', kid], :order => 'level' )
	end
	end
end