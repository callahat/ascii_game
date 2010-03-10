class CClassLevel < ActiveRecord::Base
	belongs_to :c_class

	validates_presence_of :level,:min_xp,:str,:dex,:con,:int,:mag,:dfn,:dam,:freepts

	def validate
		if level.nil?
			errors.add("level", " cannot be null.")
		elsif level <= 0
			points = 0

			if str.nil?
				errors.add("str"," cannot be null.")
			elsif str < 0
				errors.add("str"," cannot be less than zero.")
			else
				points += str
			end

			if con.nil?
				errors.add("con"," cannot be null.")
			elsif con < 0
				errors.add("con"," cannot be less than zero.")
			else
				points += con
			end
			
			if dex.nil?
				errors.add("dex"," cannot be null.")
			elsif dex < 0
				errors.add("dex"," cannot be less than zero.")
			else
				points += dex
			end

			if mag.nil?
				errors.add("mag"," cannot be null.")
			elsif mag < 0
				errors.add("mag"," cannot be less than zero.")
			else
				points += mag
			end

			if dam.nil?
				errors.add("dam"," cannot be null.")
			elsif dam < 0
				errors.add("dam"," cannot be less than zero.")
			else
				points += dam
			end

			if int.nil?
				errors.add("int"," cannot be null.")
			elsif int < 0
				errors.add("int"," cannot be less than zero.")
			else
				points += int
			end

			if dfn.nil?
				errors.add("dfn"," cannot be null.")
			elsif dfn < 0
				errors.add("dfn"," cannot be less than zero.")
			else
				points += dfn
			end

			if freepts.nil?
				errors.add("freepts"," cannot be null.")
			elsif freepts < 0
				errors.add("freepts"," cannot be less than zero.")
			else
				points += freepts
			end

			if level >= 0
				if points < 30 || points > 80
					errors.add("","Attribute points must be between 30 and 80. (Current = " + points.to_s + ")")
				end
			end

			if errors.size > 0
				return false
			else
				return true
			end

		end
	end




	#class is passed in as a parameter
	def self.next_level(c, l)
		find_by_sql("select * from c_class_levels where #{c} = c_class_id and #{l} + 1 = level") 
	end
	def self.current_level(c, l)
		find_by_sql("select * from c_class_levels where #{c} = c_class_id and #{l} = level") 
	end

	#return a class with the mod level bonuses added

	def self.xp_cost(mod)
		@xp_cost = mod.to_i * 4
		if @xp_cost <= 0
			0
		elsif @xp_cost <= 10
			@xp_cost * 2
		elsif @xp_cost <= 100
			(@xp_cost-10) * 4 + 20
		else
			(@xp_cost-100) * (@xp_cost-100) + 380
		end
	end

	def self.mod_level_bonus(level,basemod)
		if level <= 0
			basemod
		elsif level < 10
			basemod / 10.0
		elsif level < 100
			basemod / 10.0 + (level/20).floor
		else
			basemod / 10.0 + (level/15).floor
		end
	end

	def self.spell_xp(c,l)
		xp = 0
		if c.attack_spells
			xp += l * l * 15
		end
		if c.healing_spells
			xp += l * l * 15
		end
		xp
	end

	def self.calc_min_experience(cl)
		xp_cost(cl.dam) +
				xp_cost(cl.dfn) +
				xp_cost(cl.str) +
				xp_cost(cl.dex) +
				xp_cost(cl.mag) +
				xp_cost(cl.int) +
				xp_cost(cl.con) +
				xp_cost(cl.freepts) +
				spell_xp(cl.c_class,cl.level)
	end

end