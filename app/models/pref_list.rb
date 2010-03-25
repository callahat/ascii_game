class PrefList < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :kingdom

	def self.add(where,what,thing)
		@pref_list = self.new
		@pref_list.kingdom_id = where
		@pref_list.pref_list_type = SpecialCode.get_code('pref_list_type',what)
		@pref_list.thing_id = thing
		return @pref_list.save
	end

	#Pagination related stuff
	def self.per_page
		30
	end
	
	def self.get_page(page, c, o)
		paginate(:page => page, :conditions => c, :order => o)
	end
end