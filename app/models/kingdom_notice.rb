class KingdomNotice < ActiveRecord::Base
	belongs_to :kingdom
	
	validates_presence_of :text,:shown_to
	
	#Pagination related stuff
	def self.per_page
		20
	end
	
	def self.get_page(page, kid = nil)
		if kid.nil?
		paginate(:page => page, :order => '"datetime DESC"' )
	else
			paginate(:page => page, :conditions => ['kingdom_id = ?', kid], :order => '"datetime DESC"' )
	end
	end
end
