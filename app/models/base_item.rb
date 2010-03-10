class BaseItem < ActiveRecord::Base
	has_many :items
	has_one :blacksmith_skill

	has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatBaseItem'

	validates_uniqueness_of :name
	validates_presence_of :name,:dfn_mod,:dam_mod,:price,:equip_loc
	
	#Pagination related stuff
	def self.per_page
		30
	end
	
	def self.get_page(page)
		paginate(:page => page, :order => 'equip_loc,name' )
	end
end