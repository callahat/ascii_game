class HealerSkill < ActiveRecord::Base
	belongs_to :disease

	validates_presence_of :max_HP_restore, :max_MP_restore, :max_stat_restore, :min_sales
	
	#Pagination related stuff
	def self.per_page
		20
	end
	
	def self.get_page(page)
		paginate(:page => page, :order => 'min_sales' )
	end
end
