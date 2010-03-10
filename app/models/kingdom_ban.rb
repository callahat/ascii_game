class KingdomBan < ActiveRecord::Base
	belongs_to :kingdom
	belongs_to :player_character
	
	validates_presence_of :kingdom_id,:name
	
	def validate
		if player_character_id.nil?
			errors.add("name", " - Character \"" + name.to_s + "\" does not exist.")
			return false
		else
			return true
		end
	end
	
	#Pagination related stuff
	def self.per_page
		30
	end
	
	def self.get_page(page, kid = nil)
		if kid.nil?
		paginate(:page => page, :order => 'name' )
	else
			paginate(:page => page, :conditions => ['kingdom_id = ?', kid], :order => 'name' )
	end
	end
end
