class HealingSpell < ActiveRecord::Base
	belongs_to :disease

	validates_uniqueness_of :name
	validates_presence_of :name, :min_level, :min_heal, :max_heal, :mp_cost
	
	def self.find_spells(level)
		find_by_sql("select * from healing_spells where min_level <= #{level} order by min_level")
	end
	
	#battle related
	#nil if can't pay
	def pay_casting_cost(pc)
		Health.transaction do
			pc.health.lock!
			if pc.health.MP >= self.mp_cost
				pc.health.MP -= self.mp_cost
				@paid = true
			else
				@paid = false
			end
			pc.health.save!
		end
		@paid
	end
	
	#returns nil if can't cast
	def cast(pc, receiver)
		@healed = 0
		@disease = self.disease
		Health.transaction do
			receiver.health.lock!
			
			magic_heals = rand(self.max_heal - self.min_heal) + self.min_heal
			base_vs_HP = receiver.health.base_HP - receiver.health.HP
			healable = ( 0 < base_vs_HP ? base_vs_HP : 0 )
			@healed	= ( healable < magic_heals ? healable : magic_heals ).to_i
			receiver.health.HP += @healed
			
			receiver.health.save!
		end
		
		unless @disease && Illness.cure(receiver, @disease)
			@disease = nil
		end
		#return amount healed and disease cured
		return @healed, @disease
	end
	
	#Pagination related stuff
	def self.per_page
		25
	end
	
	def self.get_page(page, l = nil)
		if l.nil?
			paginate(:page => page, :order => 'min_level,name' )
		else
			paginate(:page => page, :conditions => ['min_level <= ?', l], :order => 'min_level,name' )
		end
	end
end
