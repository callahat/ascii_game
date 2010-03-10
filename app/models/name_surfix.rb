class NameSurfix < ActiveRecord::Base
	#Pagination related stuff
	def self.per_page
		25
	end
	
	def self.get_page(page)
		paginate(:page => page, :order => 'name_surfixes' )
	end
end