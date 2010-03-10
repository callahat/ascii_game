class CClass < ActiveRecord::Base
	has_many :c_class_levels
	has_many :player_characters

	has_one :level_zero, :foreign_key => 'owner_id', :class_name => 'StatCClass'
	has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatCClass'

	validates_uniqueness_of :name
	validates_presence_of :name
	
	def spell_xp(l)
		xp = 0
		if attack_spells
			xp += 15 * (l ** 1.5).to_i
		end
		if healing_spells
			xp += 15 * (l ** 1.2).to_i
		end
		xp
	end
	
	#Pagination related stuff
	def self.per_page
		10
	end
	
	def self.get_page(page)
		paginate(:page => page, :order => 'name' )
	end
end
