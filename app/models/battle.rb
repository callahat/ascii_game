class Battle < ActiveRecord::Base
	has_many :enemies,		:class_name => "BattleEnemy"
	has_many :pcs,				:class_name => "BattlePc"
	has_many :npcs,				:class_name => "BattleNpc"
	has_many :merchants,	:class_name => "BattleNpc", :conditions => {:special => SpecialCode.get_code('npc_division','merchant')}
	has_many :guards,			:class_name => "BattleNpc", :conditions => {:special => SpecialCode.get_code('npc_division','guard')}
	has_many :creatures,	:class_name => "BattleCreature"
	has_many :items,			:class_name => "BattleItem"
	has_many :groups,			:class_name => "BattleGroup"
	
	belongs_to :player_character, :foreign_key => 'owner_id', :class_name => "PlayerCharacter"
	belongs_to :owner, :foreign_key => 'owner_id', :class_name => "PlayerCharacter"
	
	attr_accessor :report
	attr_accessor :regicide
	
	#Methods for starting different kinds of new battles
	def self.storm_gates(owner, kingdom)
		@guards = self.summon_guards(kingdom, 0.5)	 #upto %70 of guards will show
		if @guards.size > 0
			b = Battle.create(:owner_id => owner.id)
			gname = @guards.size.to_s + ( @guards.size > 1 ? " guards" : " guard")
			bg = BattleGroup.create(:battle_id => b.id, :name => gname)
			spec = SpecialCode.get_code('npc_division','guard')
			@guards.each{ |g|
				BattleNpc.create(:battle_id => b.id, :enemy_id => g.id, :battle_group_id => bg.id, :special => spec) }
			return b, ""
		else
			return nil, "You met with no resistance"
		end
	end
	
	def self.new_pc_battle(owner, pc)
		if pc.health.HP <= 0
			return nil, pc.name + " is already dead."
		else
			b = Battle.create(:owner_id => owner.id)
			bg = BattleGroup.create(:battle_id => b.id, :name => pc.name)
			BattlePc.create(:battle_id => b.id, :enemy_id => pc.id, :battle_group_id => bg.id)
			return b, ""
		end
	end
	
	def self.new_npc_battle(owner, npc)
		if npc.health.HP <= 0
			return nil, npc.name + " is already dead..."
		else
			spec = SpecialCode.get_code('npc_division','guard')
			b = Battle.create(:owner_id => owner.id)
			@guards = self.summon_guards(npc.kingdom, 0.3)	 #upto %30 of guards will show
			gname = npc.name
			gname += " and " + @guards.size.to_s + ( @guards.size > 1 ? " guards" : " guard")
			bg = BattleGroup.create(:battle_id => b.id, :name => gname)
			BattleNpc.create(:battle_id => b.id, :enemy_id => npc.id, :battle_group_id => bg.id, :special => npc.npc_division)
			@guards.each{ |g|
				BattleNpc.create(:battle_id => b.id, :enemy_id => g.id, :battle_group_id => bg.id, :special => spec) }
			return b, ""
		end
	end
	
	def self.new_king_battle(owner, kingdom)
		@king = kingdom.player_character
		if @king.health.HP <= 0
			return nil, "There is no king to fight, only memories..."
		else
			spec = SpecialCode.get_code('npc_division','guard')
			b = Battle.create(:owner_id => owner.id)
			@guards = self.summon_guards(kingdom, 0.7)	 #upto %70 of guards will show
			gname = @king.name
			gname += " and " + @guards.size.to_s + ( @guards.size > 1 ? " guards" : " guard")
			bg = BattleGroup.create(:battle_id => b.id, :name => gname)
			BattlePc.create(:battle_id => b.id, :enemy_id => @king.id, :battle_group_id => bg.id)
			@guards.each{ |g|
				BattleNpc.create(:battle_id => b.id, :enemy_id => g.id, :battle_group_id => bg.id, :special => spec) }
			return b, ""
		end
	end
	
	def self.new_creature_battle(owner, creature, low, high, kingdom)
		if creature.name == 'Peasant' && kingdom
			@num = kingdom.reserve_peasants(rand(high - low + 1) + low)
			@spec = SpecialCode.get_code('npc_division','peasant')
		else
			@num = creature.reserve_creatures(rand(high - low + 1) + low)
		end
		
		if @num == 0
			return nil, "You jump at a shadow"
		else
			b = Battle.create(:owner_id => owner.id)
			gname = @num.to_s + " " + ( @num > 1 ? creature.name.pluralize : creature.name )
			bg = BattleGroup.create(:battle_id => b.id, :name => gname )
			1.upto(@num){|i|
				bc = BattleCreature.create(:battle_id => b.id, :enemy_id => creature.id, :battle_group_id => bg.id, :special => @spec)
				StatCreatureBattle.create( Stat.to_symbols_hash(creature.stat).merge(:owner_id => bc.id) )
				HealthCreatureBattle.create(:HP => creature.HP, :base_HP => creature.HP, :owner_id => bc.id )
			}
			return b, ""
		end
	end
	
	
	#methods for what happens during a battle
	#main attack call, attack = nil if physical attack, target = which group id attacked
	#returns nil if the round cannot run as requested.
	def for_this_round(pc, target, spell=nil)
		self.report = {}
		if target
			if spell.nil?
				self.phys_damage_enemies(pc, target.enemies)
			elsif spell.class == AttackSpell
				return nil unless self.mag_damage_enemies(pc, spell, target.enemies)
			else #if attack.class == HealingSpell
				return nil unless self.cast_healing_spell(pc, spell, pc)
			end
		end
		self.groups.each{|g|
			0.upto( (g.enemies.size < 10 ? g.enemies.size : 10) - 1 ){|ind|
				self.phys_damage_enemies(g.enemies[ind], [pc]) } }
	end
	
	
	#Methods for ending a battle
	def victory
		if self.enemies.size == 0
			self.groups.destroy_all
			if (@tax = (self.gold * self.owner.present_kingdom.tax_rate/100.0).to_i) > 0
				Kingdom.pay_tax(@tax, self.owner.present_kingdom)
				self.update_attribute(:gold, self.gold - @tax)
			end
			PlayerCharacter.transaction do
				self.owner.lock!
				self.owner.gold += self.gold
				self.owner.save!
			end
			@items=[]
			self.items.each{|i| PlayerCharacterItem.update_inventory(self.owner_id,i.item_id,i.quantity) 
				@items << i.quantity.to_s + " " + (i.quantity > 1 ? i.item.name.pluralize : i.item.name) }
			return {:gold => self.gold, :tax => @tax, :items => @items}
		else
			return false
		end
	end
	
	def was_owner_killed
		if self.owner.health.HP > 0
			return false
		else
			self.clear_battle
			return true
		end
	end
	
	def run_away(chance)
		if rand(100) < chance
			self.clear_battle
			return true
		else
			return false
		end
	end
	
	def clear_battle
		@creature_ids = {}
		self.creatures.each{|c|
			c.health.destroy
			c.stat.destroy
			@creature_ids[c.creature.id] = 1 + @creature_ids[c.creature.id].to_i
			c.destroy	}
		self.enemies.destroy_all
		self.items.destroy_all
		self.groups.destroy_all
		self.destroy
		@creature_ids.keys.each{|cid|
			c = Creature.find(cid)
			c.reserve_creatures(-1*@creature_ids[cid])
		}
	end
#
#these should only be called by other methods in this class, or unit tests, and probably should not be
#called via a controller directly.
	def self.summon_guards(kingdom, ratio)
		return [] if kingdom.nil?
		max_help = kingdom.guards.size * ratio
		kingdom.guards.find(:all, :order => "rand()", :limit => rand(max_help) + 1 )
	end
	
	def fighter_killed(who)
		if who.class == BattleCreature
			who.health.destroy
			who.stat.destroy
			self.update_attributes(:gold => self.gold + who.enemy.gold)
		else #only get a fractions of the gold
			self.update_attributes(:gold => self.gold + who.enemy.drop_nth_of_gold(8))
		end
		if who.class.base_class == BattleEnemy
			case who.class.name
				when "BattleCreature"
					LogQuestCreatureKill.complete_req(self.owner_id, who.enemy_id)
					peasant = (who.special == SpecialCode.get_code('npc_division','peasant'))
					LogQuestKillNNpc.complete_req(self.owner_id,who.special, self.owner.in_kingdom) if peasant
					CreatureKill.log_kill(self.owner_id,who.enemy_id,1)
				when "BattlePc"
					LogQuestKillPc.complete_req(self.owner_id,who.enemy_id)
					PlayerCharacterKiller.create(:player_character_id => self.owner_id, :killed_id => who.enemy_id)
				when "BattleNpc"
					LogQuestKillSNpc.complete_req(self.owner_id,who.enemy_id)
					LogQuestKillNNpc.complete_req(self.owner_id,who.special, self.owner.in_kingdom)
					NonplayerCharacterKiller.create(:player_character_id => self.owner_id, :npc_id => who.enemy_id)
			end
			group = who.battle_group
			who.destroy
			group.rename
		end
	end
	
	def self.award_exp_from_kill(a, killed)
		return if a.class == BattleCreature
		( killed.class.base_class == BattleEnemy ?
			a.award_exp(killed.exp_worth) :
			a.award_exp(killed.experience / 50) )
	end
	
	def phys_damage_enemies(attacker, target_array)
		self.init_report_for( Battle.get_name(attacker) )
		@max_hits = ( attacker[:level] ? attacker[:level] / 3 + 1 : 1 )
		@max_hits = 10 if @max_hits > 10
		@atk_hash = { :dealt => attacker.stat.phys_dam, :dam => attacker.stat.phys_dam }
		while (@max_hits -= 1) >= 0 && @atk_hash[:dam] > 0 && @atk_hash[:dealt] > @atk_hash[:dam] /2 && target_array.size > 0
			@ct = target_array.shift
			if Battle.attacker_hits(attacker.stat.dex, @ct.stat.dex)
				#remaining damage
				@atk_hash[:dealt] = Stat.damage_after_defense(@atk_hash[:dam], @ct.stat.dfn)
				@atk_hash[:dam] = @ct.health.inflict_damage( Stat.damage_after_defense(@atk_hash[:dam], @ct.stat.dfn) )
				Battle.spread_disease(@ct, attacker, SpecialCode.get_code('trans_method','fluid'))
				self.damage_result_helper(attacker, @ct, @atk_hash[:dealt])
			else
				self.report_miss(Battle.get_name(attacker), Battle.get_name(@ct))
			end
		end
	end
	
	#Magic damage enemies, assumes the spell is valid and the MP/HP has already been deducted
	def mag_damage_enemies(attacker, spell, target_array)
		if !attacker.c_class.attack_spells
			return (self.report_cannot_cast(attacker.name, "Attack Spells") && false )
		elsif attacker.level < spell.min_level
			return (self.report_cannot_cast(attacker.name, spell.name + ", level is too low") && false )
		elsif !spell.pay_casting_cost(attacker)
			return (self.report_cannot_cast(attacker.name, spell.name, true) && false)
		end
	
		self.init_report_for( Battle.get_name(attacker) )
		self.report_spell_cast(Battle.get_name(attacker), spell.name)
		@targets = (spell.splash ? target_array : [target_array.shift] )
		@magic_dam = spell.magic_dam(attacker.stat.int, attacker.stat.mag)
		@targets.each{|target|
			@damage = target.health.inflict_damage( Stat.damage_after_mag_res(@magic_dam, target.stat.int, target.stat.mag) )
			self.damage_result_helper(attacker, target, @damage)
		}
	end
	
	#check if defender was killed by attacker
	def damage_result_helper(attacker, defender, damage)
		if defender.health.HP <= 0
			Battle.award_exp_from_kill(attacker, defender)
			self.report_kill(Battle.get_name(attacker), Battle.get_name(defender), damage)
			if defender.class == BattlePc && defender.pc.kingdom
				self.regicide = defender.pc.kingdom_id if defender.pc.kingdom.player_character_id == defender.pc.id
			end
			self.fighter_killed(defender) unless defender.class == PlayerCharacter
		else
			self.report_hit(Battle.get_name(attacker), Battle.get_name(defender), damage)
		end
	end
	
	def cast_healing_spell(pc, spell, target)
		if !pc.c_class.healing_spells
			return (self.report_cannot_cast(pc.name, "Healing Spells") && false )
		elsif pc.level < spell.min_level
			return (self.report_cannot_cast(pc.name, spell.name + ", level is too low") && false )
		elsif !spell.pay_casting_cost(pc)
			return (self.report_cannot_cast(pc.name, spell.name, true) && false )
		end
	
		self.init_report_for( Battle.get_name(pc) )
		self.report_spell_cast(Battle.get_name(pc), spell.name)
		healed, disease = spell.cast(pc, target)
		self.report_healed(Battle.get_name(pc), Battle.get_name(target), healed, disease)
		true
	end
	
	def self.attacker_hits(atk_dex, dfn_dex)
		(rand(dfn_dex) + dfn_dex) < (rand(atk_dex) + atk_dex) || (rand(100) > 60)
	end
	
	#functions for reporting what happened to the player.
	def self.get_name(who)
		return who.enemy.name if who.class.base_class == BattleEnemy
		who.name
	end
	
	def init_report_for(name)
	p name if self.report.nil?
		self.report[name] = [] unless self.report[name].class == Array
	end
	
	def report_cannot_cast(name, spell, nep=false)
		msg = " cannot cast " + spell
		msg += ", not enough HP and/or MP" if nep
		self.report[name] = [msg]
	end
	
	def report_spell_cast(name, spell)
		self.report[name] << " casts " + spell
	end
	
	def report_kill(name, target, damage)
		self.report[name] << " hits for " + damage.to_s + " points, killing " + target
	end
	
	def report_hit(name, target, damage)
		self.report[name] << " wounds " + target + " for " + damage.to_s
	end
	
	def report_miss(name, target)
		self.report[name] << " misses " + target
	end
	
	def report_healed(name, target, hp, disease)
		self.report[name] << " healing " + target + " for " + hp.to_s + " points"
		self.report[name] << " and curing " + disease.name if disease
	end
	
	def self.spread_disease(host, target, vector)
		return if target.class == BattleCreature
		if host.class == BattleCreature
			disease = host.creature.disease
			Illness.infect(target, disease) if disease && disease.trans_method == vector
		else
			Illness.spread(host, target, vector)
		end
	end
end
