class BlacksmithSkill < ActiveRecord::Base
	belongs_to :base_item

	def self.find_base_items(sales)
		find_by_sql("select * from blacksmith_skills where min_sales <= sales order by min_sales")
	end

	validates_presence_of :min_sales,:base_item_id
	
	#Pagination related stuff
	def self.per_page
		30
	end
	
	def self.get_page(page)
		paginate(:page => page, :order => 'min_sales' )
	end
end
