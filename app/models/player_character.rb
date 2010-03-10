class PlayerCharacter < ActiveRecord::Base
	belongs_to :player
	belongs_to :kingdom
	belongs_to :image
	belongs_to :c_class
	belongs_to :race

	belongs_to :present_kingdom, :foreign_key => 'in_kingdom', :class_name => 'Kingdom'
	belongs_to :present_level, :foreign_key => 'kingdom_level', :class_name => 'Level'
	belongs_to :present_world, :foreign_key => 'in_world', :class_name => 'World'

	has_many :quest_kill_pcs
	has_many :creature_kills
	has_many :done_events
	has_many :done_quests
	has_many :genocides
	has_many :illnesses, :foreign_key => 'owner_id', :class_name => 'Infection'
	has_many :kingdoms
	has_many :kingdom_bans
	has_many :log_quests
	has_many :log_quest_creature_kills
	has_many :log_quest_explores
	has_many :log_quest_kill_n_npcs
	has_many :log_quest_kill_pcs
	has_many :log_quest_kill_s_npcs
	has_many :nonplayer_character_killers
	has_many :player_character_equip_locs
	has_many :items, :foreign_key => 'owner_id', :class_name => 'PlayerCharacterItem'
	has_many :player_character_killers
	
	has_one :health,		:foreign_key => 'owner_id', :class_name => 'HealthPc'
	has_one :stat,			:foreign_key => 'owner_id', :class_name => 'StatPc'
	has_one :trn_stat,	:foreign_key => 'owner_id', :class_name => 'StatPcTrn'
	has_one :base_stat, :foreign_key => 'owner_id', :class_name => 'StatPcBase'
	has_one :level_zero, :foreign_key => 'owner_id', :class_name => 'StatPcLevelZero'
	
	validates_presence_of :name, :race, :c_class, :player_id, :c_class_id, :race_id, :char_stat
	validates_length_of :name, :in => 1..32
	validates_uniqueness_of :name
	
	def gain_level(freedist)
		return -1, "Not enough experience to gain level." if self.experience < self.next_level_at
		return 0, "Invalid distribution" if !freedist.valid_distrib(freepts)
		
		@delta = level_zero.to_level(level + 1)
		@delta.subtract_stats(self.level_zero.to_level(level))
		p"HIT"
		Stat.transaction do
			@pc = self.dup
			p self
			p @pc
			@pc.stat.lock!
			@pc.stat.add_stats(@delta)
			@pc.stat.add_stats(freedist)
			@pc.stat.save!
			
			@pc.base_stat.lock!
			@pc.base_stat.add_stats(@delta)
			@pc.base_stat.add_stats(freedist)
			@pc.base_stat.save!

			@pc.lock!
			@pc.level += 1
			@pc.next_level_at = self.exp_for_level(level + 1)
			@pc.freepts -= freedist.sum_points
			@pc.freepts += (self.freepts * 0.05).to_i
			@pc.freepts += c_class.freepts + race.freepts
			@pc.save!
			
			@pc.health.lock!
			@pc.health.adjust_for_stats(base_stat, level)
			@pc.health.save!
		end
		return 1, "Your power grows!"
	end
	
	def exp_for_level(l)
		level_zero.dup.exp_for_level(l) + race.equip_loc_xp(l) + c_class.spell_xp(l)
	end
	
	def award_exp(exp)
		PlayerCharacter.transaction do
			self.lock!
			self.experience += exp
			self.save!
		end
	end
	
	def drop_nth_of_gold(n)
		PlayerCharacter.transaction do
			self.lock!
			@amount = self.gold / n
			self.gold -= @amount
			self.save!
		end
		@amount || 0
	end
	
protected
	after_create :setup_stats_and_health
	
	def setup_stats_and_health
		@composite = self.c_class.level_zero
		@composite.add_stats(self.race.level_zero)
		
		StatPc.create(Stat.to_symbols_hash(@composite).merge(:owner_id => self.id))
		StatPcBase.create(Stat.to_symbols_hash(@composite).merge(:owner_id => self.id))
		StatPcTrn.create(:owner_id => self.id)
		StatPcLevelZero.create(Stat.to_symbols_hash(@composite).merge(:owner_id => self.id))
		
		newhealth = HealthPc.create(:owner_id => self.id)
		newhealth.adjust_for_stats(self.base_stat, 1)
		newhealth.wellness = SpecialCode.get_code('wellness','alive')
		newhealth.save
		
		lvl_zero = self.level_zero.dup
		r = self.race.dup
		c = self.c_class.dup
		
		self.next_level_at = self.exp_for_level(1)
		self.save
	end
end