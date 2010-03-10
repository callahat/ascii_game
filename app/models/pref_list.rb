class PrefList < ActiveRecord::Base
	belongs_to :kingdom
	belongs_to :event, :foreign_key => 'thing_id', :class_name => 'Event'
	belongs_to :creature, :foreign_key => 'thing_id', :class_name => 'Creature'
	belongs_to :feature, :foreign_key => 'thing_id', :class_name => 'Feature'
	
	def self.add(where,what,thing)
		@pref_list = self.new
		@pref_list.kingdom_id = where
		@pref_list.pref_list_type = SpecialCode.get_code('pref_list_type',what)
		@pref_list.thing_id = thing
		return @pref_list.save
	end
	
	def thing
		case self.pref_list_type
			when SpecialCode.get_code('pref_list_type','creatures')
				self.creature
			when SpecialCode.get_code('pref_list_type','events')
				self.event
			when SpecialCode.get_code('pref_list_type','features')
				self.feature
		end
			
	end
	
	#Pagination related stuff
	def self.per_page
		30
	end
	
	def self.get_page(page, c, o)
		paginate(:page => page, :conditions => c, :order => o)
	end
end