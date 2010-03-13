require 'test_helper'

class BattleTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@sickpc = PlayerCharacter.find_by_name("sick pc")
		@king = PlayerCharacter.find_by_name("Test King")
		
		@npc = Npc.find_by_name("Healthy Npc")
		@sick_npc = Npc.find_by_name("Sick NPC")
		
		@sars = Disease.find_by_name("airbourne disease")
		@not_sars = Disease.find_by_name("contact disease")
		@fluid_disease = Disease.find_by_name("fluid disease")
		
		@hp_heal = HealingSpell.find_by_name("Heal Only")
		@cure_sars = HealingSpell.find_by_name("Cure Sars")
		@cure_and_heal = HealingSpell.find_by_name("Cure Sars and Heal")
		
		@weak_spell = AttackSpell.find_by_name("Weak Attack Spell")
		@strong_spell = AttackSpell.find_by_name("Strong Attack Spell")
		@splash_spell = AttackSpell.find_by_name("Splash Attack Spell")
		
	  @kingdom = Kingdom.find_by_name("HealthyTestKingdom")
		
		@peasants = Creature.find_by_name("Peasant")
		@wild_foo = Creature.find_by_name("Wild foo")
		@wimp_c = Creature.find_by_name("Wimp Monster")
		@hard_c = Creature.find_by_name("Tough Monster")
		
		@quest = Quest.find_by_name("Quest One")
	end

	test "new creature battles" do
		@orig_alive = @wild_foo.number_alive
		@orig_fought = @wild_foo.being_fought
		battle, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, @pc.in_kingdom)
		assert battle && msg == ""
		assert battle.groups.size == 1, battle.groups
		assert battle.groups.first.name == "5 Wild foos"
		assert battle.creatures.size == 5, "Enemies:" + battle.creatures.size.to_s
		assert battle.creatures[0].stat == battle.creatures[0].stat
		assert StatCreatureBattle.count == 5
		assert HealthCreatureBattle.count == 5
		assert battle.creatures[0].stat != battle.creatures[1].stat
		battle.creatures.each{|e|
		  assert e.stat
			assert e.health }
		@wild_foo.reload
		assert @wild_foo.number_alive == @orig_alive - 5
		assert @wild_foo.being_fought == @orig_fought + 5
		
		#fighting more than exist
		battle2, msg = Battle.new_creature_battle(@pc, @wild_foo, @orig_alive + 5, @orig_alive + 5, @pc.present_kingdom)
		assert battle2 && msg == ""
		assert battle2.groups.size == 1, battle.groups
		assert battle2.enemies.size == @orig_alive - 5, "Enemies:" + battle.enemies.size.to_s
		@wild_foo.reload
		assert @wild_foo.number_alive == 0
		assert @wild_foo.being_fought == @orig_alive

		#fighting creature with none free/extinct
		battle3, msg = Battle.new_creature_battle(@pc, @wild_foo, 1, 5, @pc.in_kingdom)
		assert !battle3 && msg != ""
		assert @wild_foo.number_alive == 0
		
		assert StatCreatureBattle.count == @orig_alive
		assert HealthCreatureBattle.count == @orig_alive
	end
	
	test "Peasant battles in a kingdom" do
		@orig_peasants = @kingdom.num_peasants
		battle, msg = Battle.new_creature_battle(@pc, @peasants, 100, 100, @kingdom)
		assert battle && msg == ""
		assert battle.groups.size == 1, battle.groups
		assert battle.creatures.size == 100, "Enemies:" + battle.creatures.size.to_s
		@kingdom.reload
		assert @kingdom.num_peasants == @orig_peasants - 100
		
		battle2, msg = Battle.new_creature_battle(@pc, @peasants, @orig_peasants, @orig_peasants, @kingdom)
		assert battle2 && msg == ""
		assert battle2.groups.size == 1, battle.groups
		assert battle2.creatures.size == @orig_peasants-100, "Enemies:" + battle2.creatures.size.to_s
		assert @kingdom.num_peasants == 0
		
		#try fighting peasants in a kingdom with none
		battle3, msg = Battle.new_creature_battle(@pc, @peasants, 1, 1, @kingdom)
		assert !battle3 && msg != ""
		assert @kingdom.num_peasants == 0
		
		assert StatCreatureBattle.count == @orig_peasants
		assert HealthCreatureBattle.count == @orig_peasants
	end
	
	test "battle a king" do
		battle, msg = Battle.new_king_battle(@pc, @kingdom)
		assert battle && msg == ""
		assert battle.pcs.size == 1
		assert battle.npcs.size > 0 && battle.npcs.size < 11, battle.npcs.size
		assert battle.pcs[0].stat == @kingdom.player_character.stat
		assert battle.npcs[0].stat == battle.npcs[0].npc.stat
		assert battle.regicide.nil?
		
		@kingdom.player_character.health.HP = 0
		#try fighting dead king
		battle2, msg = Battle.new_king_battle(@pc, @kingdom)
		assert !battle2 && msg != "", battle2
	end
	
	test "failed regicide" do
		battle, msg = Battle.new_king_battle(@pc, @kingdom)
		battle.npcs.destroy_all #make sure no NPC's in way
		battle.enemies.first.health.update_attributes(:HP => 300)
		assert battle.regicide.nil?
		battle.report = {}
		assert battle.enemies.size == 1
		battle.phys_damage_enemies(@pc, battle.groups.first.enemies)
		assert battle.enemies.size == 1
		assert battle.regicide.nil?
	end
	
	test "successful regicide" do
		battle, msg = Battle.new_king_battle(@pc, @kingdom)
		battle.npcs.destroy_all #make sure no NPC's in way
		battle.enemies.first.health.update_attributes(:HP => 3)
		battle.enemies.first.stat.update_attributes(:dex => 0)
		assert battle.regicide.nil?
		battle.report = {}
		assert battle.enemies.size == 1
		battle.phys_damage_enemies(@pc, battle.groups.first.enemies)
		assert battle.enemies.size == 0,battle.enemies.size
		assert battle.regicide == @kingdom.id
	end
	
	test "gate storm battle" do
		battle, msg = Battle.storm_gates(@pc, @kingdom)
		assert battle && msg == ""
		assert battle.npcs.size > 0 && battle.npcs.size < 11
		
		#Kingdom has no guards to defend the gates
		@kingdom2 = Kingdom.find_by_name("SickTestKingdom")
		battle2, msg = Battle.storm_gates(@pc, @kingdom2)
		assert battle2.nil? && msg != ""
	end
	
	test "battle an npc" do
		battle, msg = Battle.new_npc_battle(@pc, @npc)
		assert battle && msg == ""
		
		#try fighting dead npc
		@npc.health.HP = 0
		battle2, msg = Battle.new_npc_battle(@pc, @npc)
		assert !battle2 && msg != ""
	end
	
	test "misc helpers" do
		#Main purpose is to assert no errors
		@result = Battle.attacker_hits(@pc.stat.dex, @wild_foo.stat.dex)
		assert @result == true || @result == false
		
		#Test the reporting
		battle, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		assert battle.report.nil?, battle.report.inspect
		assert Battle.get_name(@pc) == @pc.name
		assert Battle.get_name(battle.enemies[0]) == "Wild foo"
		
		battle.report = {}
		pc_name = Battle.get_name(@pc)
		c_name = "Wild foo"
		assert battle.init_report_for(pc_name)
		assert battle.report[pc_name] == []
		battle.report_miss(pc_name, c_name)
		assert battle.report[pc_name].last == " misses " + c_name
		battle.report_hit(pc_name, c_name, 10)
		assert battle.report[pc_name].last == " wounds " + c_name + " for " + 10.to_s
		battle.report_kill(pc_name, c_name, 50)
		assert battle.report[pc_name].last == " hits for " + 50.to_s + " points, killing " + c_name
		assert battle.report[pc_name].size == 3
	end
	
	test "summon guards" do
		0.upto(20){
			@guards = Battle.summon_guards(@kingdom, 0.5)
			assert @guards.size > 0 && @guards.size < 6, @guards.size }
	end
	
	test "spread disease from creature" do
		battle, msg = Battle.new_creature_battle(@pc, @wild_foo, 1, 1, nil)
		
		#can't catch nothing if creature doesn't carry it
		assert @pc.illnesses.size == 0
		Battle.spread_disease(battle.enemies[0], @pc, SpecialCode.get_code('trans_method','fluid'))
		assert @pc.illnesses.size == 0
		
		#can't catch disease with wrong trans type
		battle.enemies[0].creature.disease = @air_disease
		assert @pc.illnesses.size == 0
		Battle.spread_disease(battle.enemies[0], @pc, SpecialCode.get_code('trans_method','fluid'))
		assert @pc.illnesses.size == 0
		
		#uh oh caught it
		battle.enemies[0].creature.disease = @fluid_disease
		assert @pc.illnesses.size == 0
		Battle.spread_disease(battle.enemies[0], @pc, SpecialCode.get_code('trans_method','fluid'))
		assert @pc.illnesses.size == 1
		assert @pc.illnesses[0].disease == @fluid_disease
	end
	
	test "spread disease from character" do
		battle, msg = Battle.new_npc_battle(@pc, @sick_npc)
		
		#can't catch disease with wrong trans type
		assert @pc.illnesses.size == 0
		Battle.spread_disease(battle.enemies[0], @pc, SpecialCode.get_code('trans_method','fluid'))
		assert @pc.illnesses.size == 0
		
		#uh oh caught it
		Illness.infect(@sick_npc, @fluid_disease)
		assert @pc.illnesses.size == 0
		Battle.spread_disease(battle.enemies[0], @pc, SpecialCode.get_code('trans_method','fluid'))
		assert @pc.illnesses.size == 1
		assert @pc.illnesses[0].disease == (@fluid_disease)
	end
	
	test "fighter killed" do
		#creature killed
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		enemies = battle1.enemies.size
		enemy1 = battle1.creatures.first
		cgold = enemy1.creature.gold
		assert cstatid = enemy1.stat.id
		assert chealthid = enemy1.health.id
		assert battle1.gold == 0
		
		battle1.fighter_killed(enemy1)
		assert battle1.enemies.size == enemies -1
		assert battle1.gold == cgold
		assert Stat.exists?(cstatid) == false
		assert Health.exists?(chealthid) == false
	end
	
	test "exp awarded" do
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 1, 1, nil)
		battle2, msg = Battle.new_npc_battle(@pc, @npc)
	
		#creature
		pc_orig_exp = @pc.experience
		Battle.award_exp_from_kill(@pc, battle1.enemies[0])
		assert @pc.experience == pc_orig_exp + battle1.enemies[0].exp_worth
		
		#character
		pc_orig_exp = @pc.experience
		Battle.award_exp_from_kill(@pc, battle2.enemies[0])
		assert @pc.experience == pc_orig_exp + battle2.enemies[0].exp_worth
		assert battle2.enemies[0].exp_worth == @npc.experience / 10
		
		#creature
		c_orig_exp = @wild_foo.experience
		Battle.award_exp_from_kill(@wild_foo, battle2.enemies[0])
		assert c_orig_exp == @wild_foo.experience
		
		#the player gets killed
		npc_orig_exp = @npc.experience
		Battle.award_exp_from_kill(@npc, @pc)
		assert @npc.experience == npc_orig_exp + @pc.experience / 50
	end
	
	test "physical damage sub" do
		#Normal attack, unlikely the enemy will be killed
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		battle1.report = {}
		assert battle1.enemies.size == 5
		battle1.phys_damage_enemies(@pc, battle1.groups.first.enemies)
		assert battle1.report[@pc.name].first =~ /wound|miss/ , battle1.report[@pc.name].first
		assert battle1.enemies.size == 5
		
		#Enemy will be killed
		orig_xp = @pc.experience
		battle2, msg = Battle.new_creature_battle(@pc, @wimp_c, 10, 10, nil)
		battle2.report = {}
		assert battle2.enemies.size == 10
		battle2.phys_damage_enemies(@pc, battle2.groups.first.enemies)
		assert battle2.report[@pc.name].first =~ /kill/, battle2.report[@pc.name].first
		assert battle2.enemies.size == 9
		assert @pc.experience == orig_xp + @wimp_c.experience
		
		#multiple hits
		orig_xp = @pc.experience
		orig_gold = @pc.gold
		@pc.level = 3 #should give two hits
		battle3, msg = Battle.new_creature_battle(@pc, @wimp_c, 10, 10, nil)
		battle3.report = {}
		assert battle3.enemies.size == 10
		assert battle3.groups.first.name == "10 Wimp Monsters"
		battle3.phys_damage_enemies(@pc, battle3.groups.first.enemies)
		assert battle3.report[@pc.name].size == 2
		assert battle3.report[@pc.name][0] =~ /kill/, battle3.report[@pc.name][0]
		assert battle3.report[@pc.name][1] =~ /kill/, battle3.report[@pc.name][1]
		assert battle3.enemies.size == 8
		assert battle3.groups.first.name == "8 Wimp Monsters",battle3.groups.first.name 
		assert @pc.experience == orig_xp + @wimp_c.experience * 2
		assert battle3.gold == @wimp_c.gold * 2
		
		#hard monster hits pc fatally
		battle4, msg = Battle.new_creature_battle(@pc, @hard_c, 2, 2, nil)
		battle4.report = {}
		battle4.phys_damage_enemies(battle4.enemies.first, [@pc])
		assert battle4.report[@hard_c.name].size == 1
		assert battle4.report[@hard_c.name][0] =~ /kill/
	end
	
	test "magic damage sub" do
		orig_xp = @pc.experience
		#Cannot cast attack spells
		battle1, msg = Battle.new_creature_battle(@pc, @wimp_c, 5, 5, nil)
		battle1.report = {}
		assert battle1.enemies.size == 5
		battle1.mag_damage_enemies(@pc, @weak_spell, battle1.groups.first.enemies)
		assert battle1.report[@pc.name][0] =~ /cannot cast Attack/, battle1.report[@pc.name]
		assert battle1.enemies.size == 5
		
		@pc.c_class.update_attributes(:attack_spells => true)
		@pc.health.update_attributes(:MP => 0)
		
		#level too low
		battle1, msg = Battle.new_creature_battle(@pc, @wimp_c, 5, 5, nil)
		battle1.report = {}
		assert battle1.enemies.size == 5
		battle1.mag_damage_enemies(@pc, @weak_spell, battle1.groups.first.enemies)
		assert battle1.report[@pc.name][0] =~ /level is too low/, battle1.report[@pc.name]
		assert battle1.enemies.size == 5
		
		@pc.update_attributes(:level => 30)
		
		#Not enough hp/mp
		battle1, msg = Battle.new_creature_battle(@pc, @wimp_c, 5, 5, nil)
		battle1.report = {}
		assert battle1.enemies.size == 5
		battle1.mag_damage_enemies(@pc, @weak_spell, battle1.groups.first.enemies)
		assert battle1.report[@pc.name][0] =~ /not enough HP and\/or MP/, battle1.report[@pc.name]
		assert battle1.enemies.size == 5
		
		@pc.health.update_attributes(:MP => 60)
		
		#single damage
		battle1, msg = Battle.new_creature_battle(@pc, @wimp_c, 5, 5, nil)
		battle1.report = {}
		assert battle1.enemies.size == 5
		assert @pc.health.MP == 60
		battle1.mag_damage_enemies(@pc, @weak_spell, battle1.groups.first.enemies)
		assert battle1.report[@pc.name][0] =~ /cast/, battle1.report[@pc.name]
		assert battle1.report[@pc.name][1] =~ /kill/, battle1.report[@pc.name].first
		assert battle1.enemies.size == 4
		assert @pc.health.MP == 55
		assert @pc.experience == orig_xp + @wimp_c.experience
		
		#splash, should kill all these NPCs
		battle2, msg = Battle.storm_gates(@pc, @kingdom)
		battle2.report = {}
		num_orig_guards = battle2.npcs.size
		assert @pc.health.MP == 55
		battle2.mag_damage_enemies(@pc, @splash_spell, battle2.groups.first.enemies)
		assert battle2.report[@pc.name].size == num_orig_guards + 1
		assert @pc.health.MP == 15
		assert battle2.npcs.size == 0
	end
	
	test "healing spell" do
		battle = Battle.new #might be able to get away with this
		
		assert Illness.infect(@pc, @sars)
		assert Illness.infect(@pc, @not_sars)
		@pc.health.update_attributes(:HP => 10, :MP => 0)
		
		#cannot cast healing spells
		battle.report = {}
		battle.cast_healing_spell(@pc, @hp_heal, @pc)
		assert battle.report[@pc.name][0] =~ /cannot cast Healing/, battle.report[@pc.name]
		assert @pc.health.HP == 10
		
		@pc.c_class.update_attributes(:healing_spells => true)
		
		#level too low
		battle.report = {}
		battle.cast_healing_spell(@pc, @hp_heal, @pc)
		assert battle.report[@pc.name][0] =~ /level is too low/, battle.report[@pc.name]
		assert @pc.health.HP == 10
		
		@pc.update_attributes(:level => 30)
		
		#not enough MP
		battle.report = {}
		battle.cast_healing_spell(@pc, @hp_heal, @pc)
		assert battle.report[@pc.name][0] =~ /not enough HP and\/or MP/, battle.report[@pc.name]
		assert @pc.health.HP == 10
		
		@pc.health.update_attributes(:MP => 100)
		
		#heal HP only
		battle.report = {}
		assert @pc.health.MP == 100
		assert @pc.health.HP == 10
		battle.cast_healing_spell(@pc, @hp_heal, @pc)
		assert @pc.health.HP == 25
		assert @pc.health.MP == 90
		assert battle.report[@pc.name][0] =~ /cast/, battle.report[@pc.name].inspect
		assert battle.report[@pc.name][1] =~ /healing/, battle.report[@pc.name].inspect
		
		#heal up to Max HP
		battle.report = {}
		assert @pc.health.MP == 90
		assert @pc.health.HP == 25
		battle.cast_healing_spell(@pc, @hp_heal, @pc)
		assert @pc.health.HP == 30
		assert @pc.health.MP == 80
		assert battle.report[@pc.name][0] =~ /cast/, battle.report[@pc.name].inspect
		assert battle.report[@pc.name][1] =~ /healing/, battle.report[@pc.name].inspect
		
		#heal zero since at max HP
		battle.report = {}
		assert @pc.health.MP == 80
		assert @pc.health.HP == 30
		battle.cast_healing_spell(@pc, @hp_heal, @pc)
		assert @pc.health.HP == 30
		assert @pc.health.MP == 70
		assert battle.report[@pc.name][0] =~ /cast/, battle.report[@pc.name].inspect
		assert battle.report[@pc.name][1] =~ /healing/, battle.report[@pc.name].inspect
		
		#heal disease
		battle.report = {}
		assert @pc.health.MP == 70
		assert @pc.health.HP == 30
		assert @pc.illnesses.size == 2
		battle.cast_healing_spell(@pc, @cure_sars, @pc)
		assert @pc.health.HP == 30
		assert @pc.health.MP == 40,@pc.health.MP
		assert @pc.illnesses.size == 1
		assert battle.report[@pc.name][0] =~ /cast/, battle.report[@pc.name].inspect
		assert battle.report[@pc.name][1] =~ /healing/, battle.report[@pc.name].inspect
		
		assert Illness.infect(@pc, @sars)
		@pc.health.update_attributes(:HP => 14, :MP => 50)
		
		#heal HP and disease
		battle.report = {}
		assert @pc.health.MP == 50
		assert @pc.health.HP == 14
		assert @pc.illnesses.size == 2
		battle.cast_healing_spell(@pc, @cure_and_heal, @pc)
		assert @pc.health.HP == 30
		assert @pc.health.MP == 0
		assert @pc.illnesses.size == 1
		assert battle.report[@pc.name][0] =~ /cast/, battle.report[@pc.name].inspect
		assert battle.report[@pc.name][2] =~ /curing/, battle.report[@pc.name].inspect
	end
	
	test "for this round hub function" do
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		assert battle1.enemies
		assert battle1.for_this_round(@pc, battle1.groups[0])
		assert battle1.report[@pc.name].size == 1
		assert battle1.report[@wild_foo.name].size > 2, battle1.report[@wild_foo.name].inspect
	end
	
	test "clear battle" do
		orig_alive = @wild_foo.number_alive
		orig_fought = @wild_foo.being_fought
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		assert battle1.clear_battle
		assert battle1.enemies.size == 0
		assert battle1.groups.size == 0
		assert !Battle.exists?(battle1.id)
	end
	
	test "run away" do
		orig_alive = @wild_foo.number_alive
		orig_fought = @wild_foo.being_fought
		
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		battle1.report = {}
		assert battle1.enemies.size == 5
		assert @wild_foo.being_fought == orig_fought + 5
		assert @wild_foo.number_alive == orig_alive - 5
		assert !battle1.run_away(0)    #  0% chance of running away
		@wild_foo.reload
		assert @wild_foo.being_fought == orig_fought + 5
		assert @wild_foo.number_alive == orig_alive - 5
		assert battle1.run_away(100)   #100% chance of running away
		@wild_foo.reload
		assert @wild_foo.being_fought == orig_fought, @wild_foo.being_fought
		assert @wild_foo.number_alive == orig_alive, @wild_foo.number_alive 
		assert battle1.enemies.size == 0
		assert !Battle.exists?(battle1.id)
	end
	
	test "owner not killed" do
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		@pc.health.update_attributes(:HP => 3)
		assert !battle1.was_owner_killed
		assert battle1.enemies.size == 5
	end
	
	test "owner killed" do
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		@pc.health.update_attributes(:HP => 0)
		assert battle1.was_owner_killed
		assert battle1.enemies.size == 0
		assert !Battle.exists?(battle1.id)
	end
	
	test "victory" do
		battle1, msg = Battle.new_creature_battle(@pc, @wild_foo, 5, 5, nil)
		assert !battle1.victory
		
		orig_xp = @pc.experience
		orig_gold = @pc.gold
		battle2, msg = Battle.new_creature_battle(@pc, @wimp_c, 1, 1, nil)
		battle2.report = {}
		assert battle2.enemies.size == 1
		battle2.phys_damage_enemies(@pc, battle2.groups.first.enemies)
		assert gold = battle2.victory
		assert wimp_gold = @wimp_c.gold
		assert battle2.enemies.size == 0
		assert @pc.experience == orig_xp + @wimp_c.experience
		@pc.reload
		assert @pc.gold == orig_gold + @wimp_c.gold, @pc.gold.to_s + " " + (orig_gold + @wimp_c.gold).to_s
	end
	
	
	test "fighter killed completion of a quest req" do
		joined, msg = LogQuest.join_quest(@pc, @quest.id)
		
		battle, msg = Battle.new_creature_battle(@pc, @wild_foo, 9, 9, @pc.in_kingdom)
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.first.quantity == 10
		
		assert battle.fighter_killed(battle.enemies.first)
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.first.quantity == 9
	end
	
	test "test quest log completion for kill creature" do
		joined, msg = LogQuest.join_quest(@pc, @quest.id)
		battle, msg = Battle.new_creature_battle(@pc, @wild_foo, 9, 9, @pc.in_kingdom)
		
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.first.quantity == 10
		
		@pc.c_class.update_attributes(:attack_spells => true)
		@pc.health.update_attributes(:MP => 100) #just so he can hit'em with the spells
		@pc.update_attributes(:level => 50)
		
		battle.report={}
		assert battle.mag_damage_enemies(@pc, @splash_spell, battle.groups.first.enemies), battle.report
		battle.enemies.reload
		assert battle.enemies.size == 0, battle.enemies.size
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.first.quantity == 1
		assert battle.victory
		
		battle, msg = Battle.new_creature_battle(@pc, @wild_foo, 3, 3, @pc.in_kingdom)
		battle.report={}
		battle.mag_damage_enemies(@pc, @splash_spell, battle.groups.first.enemies)
		assert battle.enemies.size == 0
		assert @pc.log_quests.find_by_quest_id(@quest.id).creature_kills.size == 0
	end
	
	test "test quest log completion for kill pc" do
		joined, msg = LogQuest.join_quest(@pc, @quest.id)
		battle, msg = Battle.new_pc_battle(@pc, @sickpc)
		
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_pcs.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_pcs.first.detail.to_i == @sickpc.id
		
		battle.report = {}
		assert battle.enemies.size == 1
		battle.phys_damage_enemies(@pc, battle.groups.first.enemies)
		assert battle.enemies.size == 0
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_pcs.size == 0
	end
	
	test "test quest log completion for kill specific npc" do
		joined, msg = LogQuest.join_quest(@pc, @quest.id)
		battle, msg = Battle.new_npc_battle(@pc, @sick_npc)
		
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_s_npcs.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_s_npcs.first.detail.to_i == @sick_npc.id
		
		battle.report = {}
		assert battle.merchants.size == 1, battle.merchants.size
		battle.phys_damage_enemies(@pc, battle.merchants)
		assert battle.merchants.size == 0
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_s_npcs.size == 0
	end
	
	test "test quest log completion for kill number of npcs" do
		joined, msg = LogQuest.join_quest(@pc, @quest.id)
		battle, msg = Battle.new_creature_battle(@pc, @peasants, 16, 16, @pc.present_kingdom)
		
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_n_npcs.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_n_npcs.first.quantity == 20
		
		@pc.c_class.update_attributes(:attack_spells => true)
		@pc.health.update_attributes(:MP => 100) #just so he can hit'em with the spells
		@pc.update_attributes(:level => 50)
		
		battle.report={}
		assert battle.mag_damage_enemies(@pc, @splash_spell, battle.groups.first.enemies), battle.report
		battle.enemies.reload
		assert battle.enemies.size == 0, battle.enemies.size
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_n_npcs.size == 1
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_n_npcs.first.quantity == 4
		assert battle.victory
		
		battle, msg = Battle.new_creature_battle(@pc, @peasants, 8, 8, @pc.present_kingdom)
		battle.report={}
		battle.mag_damage_enemies(@pc, @splash_spell, battle.groups.first.enemies)
		assert battle.enemies.size == 0
		assert @pc.log_quests.find_by_quest_id(@quest.id).kill_n_npcs.size == 0
	end
	
end