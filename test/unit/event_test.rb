require 'test_helper'

class EventTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
		@kingdom = Kingdom.find(1)
		@disease = Disease.find_by_name("airbourne disease")
	end

	test "quest event" do
		eq = EventQuest.find_by_name("Quest event")
		direct, comp, msg = eq.happens(@pc)
		assert comp == true
		assert msg =~ /thunderous/
		assert eq.quest.name == "Quest One"
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = eq.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create quest event" do
		e = EventQuest.new(@standard_new)
		assert e.valid?
		assert e.errors.full_messages.size == 0
		e.text = "Quest text"
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "creature event" do
		ec = EventCreature.find_by_name("Weak Monster encounter")
		assert ec.creature.name == "Wimp Monster"
		assert_difference 'Battle.count', +1 do
			@direct, @comp, @msg = ec.happens(@pc)
		end
		assert @direct.class == Hash
		assert @direct[:controller] == 'game/battle'
		
		#test where there are no living creatures
		ec.creature.update_attribute(:number_alive, 0)
		assert_difference 'Battle.count', +0 do
			@direct, @comp, @msg = ec.happens(PlayerCharacter.find(1))
		end
		ec.creature.update_attribute(:number_alive, 1000)
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ec.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create creature event" do
		e = EventCreature.new(@standard_new.merge(:flex => "0;0"))
		assert !e.valid?
		assert e.errors.full_messages.size == 3, e.errors.full_messages
		e.creature = Creature.find(:first)
		assert !e.valid?
		assert e.errors.full_messages.size == 2, e.errors.full_messages.size
		e.flex = "4;9"
		assert e.valid?,e.errors.full_messages
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "pc event" do
		ep = EventPlayerCharacter.find_by_name("Sick PC encounter")
		assert ep.player_character.name == "sick pc"
		direct, comp, msg = ep.happens(@pc)
		assert comp == true
		
		ep.player_character.health.update_attribute(:HP, 0)
		direct, comp, msg = ep.happens(@pc)
		assert direct.class == Hash
		assert msg =~ /mortal/
		ep.player_character.health.update_attribute(:HP, 70)
		
		#assert not fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ep.happens(@pc)
		assert comp == true
	end
	
	test "create pc event" do
		e = EventPlayerCharacter.new(@standard_new)
		assert !e.valid?, e.errors.full_messages
		assert e.errors.full_messages.size == 1, e.errors.full_messages
		e.player_character = PlayerCharacter.find(:first)
		assert e.valid?, e.errors.full_messages
		assert e.errors.full_messages.size == 0, e.errors.full_messages
		assert e.save!
	end
	
	test "item event" do
		ei = EventItem.find_by_name("Item event")
		assert @pc.items.find(:all, :conditions => {:item_id => ei.thing_id}).size == 0
		assert ei.item.name == "Cool item"
		assert_difference '@pc.items.size', +1 do
			direct,comp,msg = ei.happens(@pc)
			@pc.items.reload
		end
		assert @pc.items.find(:first, :conditions => {:item_id => ei.thing_id}).quantity == 3
		
		assert_difference '@pc.items.size', +0 do
			direct,comp,msg = ei.happens(@pc)
			@pc.items.reload
		end
		assert @pc.items.find(:first, :conditions => {:item_id => ei.thing_id}).quantity == 6
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ei.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create item event" do
		e = EventItem.new(@standard_new.merge(:flex => 105))
		assert !e.valid?
		assert e.errors.full_messages.size == 2
		e.item = Item.find_by_name("Item99")
		assert !e.valid?
		assert e.errors.full_messages.size == 1, e.errors.full_messages.size
		e.flex = 4
		assert e.valid?,e.errors.full_messages
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "disease event" do
		ed = EventDisease.find_by_name("Airborn disease event")
		assert !@pc.illnesses.exists?(:disease_id => ed.thing_id)
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
		assert @pc.illnesses.size == 0
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], -5 do
			direct,comp,msg = ed.happens(@pc)
			assert comp == true
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 1
		assert @pc.health.wellness == SpecialCode.get_code('wellness','diseased')
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +0 do
			direct,comp,msg = ed.happens(@pc)
			assert msg =~ /unhealthy/
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 1
		
		ed.flex = 1
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +5 do
			direct,comp,msg = ed.happens(@pc)
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 0
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +0 do
			direct,comp,msg = ed.happens(@pc)
			assert msg =~ /Nothing/
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 0
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ed.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create disease event" do
		e = EventDisease.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1
		e.disease = Disease.find(:first)
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "stat event" do
		es = EventStat.find_by_name("Stat event")
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +10 do
			assert_difference '@pc.gold', +500 do
				assert_difference '@pc.experience', +10 do
					assert_difference ['@pc.health.MP','@pc.health.HP'], +30 do
						direct,comp,msg = es.happens(@pc)
						assert comp == true
						assert msg =~ /explaining/
						@pc.stat.reload
						@pc.health.reload
					end
				end
			end
		end
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = es.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create stat event" do
		e = EventStat.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1
		e.flex = "9001;25"
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "storm gate" do
		es = EventStormGate.find_by_name("Storm Kingdom 1 Gate event")
		assert_difference 'Battle.count', +1 do
			@direct, @comp, @msg = es.happens(@pc)
		end
		assert @direct.class == Hash
		assert @direct[:controller] == 'game/battle'
		
		#test where there are no guards
		es.level.kingdom.npcs.destroy_all
		assert_difference 'Battle.count', +0 do
			@direct, @comp, @msg = es.happens(PlayerCharacter.find(1))
		end
		assert @comp == true
		assert @msg =~ /no resistance/
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = es.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create storm gate" do
		e = EventStormGate.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1, e.errors.full_messages
		e.level = Level.find(:first)
		assert e.valid?,e.errors.full_messages
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "world move event" do
		el = EventMoveWorld.find_by_name("world move event")
		@pc.present_kingdom = @kingdom
		@pc.kingdom_level = @kingdom.levels.first
		direct, comp, msg = el.happens(@pc)
		assert @pc.in_kingdom.nil?
		assert @pc.kingdom_level.nil?
		assert comp == true
	end
	
	test "create world move event" do
		e = EventMoveWorld.new(@standard_new)
		assert e.valid?
		assert e.save!
	end
	
	test "local relative move event" do
		e = EventMoveRelative.find_by_name("relative move event")
		direct, comp, msg = e.happens(@pc)
		assert msg =~ /in the world/
		
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find(:first, :conditions => ['level = 0']).id
		@pc.save!
		assert @pc.present_level.level == 0, @pc.present_level
		direct, comp, msg = e.happens(@pc)
		@pc.reload
		assert @pc.present_level.level == -1
		
		direct, comp, msg = e.happens(@pc)
		@pc.reload
		assert msg =~ /UNDER CONSTRUCTION/
		assert @pc.present_level.level == -1
	end
	
	test "create relative move event" do
		e = EventMoveRelative.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1
		e.flex = '1'
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "local move event when in kingdom" do
		e = EventMoveLocal.find_by_name("local move event")
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find(:first, :conditions => ['level = -1']).id
		
		direct, comp, msg = e.happens(@pc)
		@pc.reload
		assert @pc.present_level == e.level, @pc.kingdom_level.to_s + " " + e.level.to_s
	end
	
	test "local move event when in world and pc banned" do
		e = EventMoveLocal.find_by_name("local move event")
		KingdomBan.create(:kingdom_id => e.level.kingdom.id, :player_character_id => @pc.id, :name => @pc.name)
		
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom.nil?
		assert @pc.kingdom_level.nil?
		assert msg =~ /prevented from entry/
	end
	
	test "local move even when in world and no one allowed in" do
		e = EventMoveLocal.find_by_name("local move event")
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','no one'))
	
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom.nil?, @pc.in_kingdom
		assert @pc.kingdom_level.nil?
		assert msg =~ /one may enter/
	end
	
	test "local move event when in world only allies pc not ally" do
		e = EventMoveLocal.find_by_name("local move event")
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','allies'))
		
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom.nil?, @pc.in_kingdom
		assert @pc.kingdom_level.nil?
		assert msg =~ /Only the kings men may pass/
	end
	
	test "local move event when in world only allies pc ally" do
		e = EventMoveLocal.find_by_name("local move event")
		@pc.update_attribute(:kingdom_id, @kingdom.id)
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','allies'))
		
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom == @kingdom.id
		assert @pc.present_level.level == 0
		assert msg =~ /Entered/
	end
	
	test "local move event everyone can enter" do
		e = EventMoveLocal.find_by_name("local move event")
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom == @kingdom.id
		assert @pc.present_level.level == 0
		assert msg =~ /Entered/
	end
	
	test "local move event infect kingdom" do
		e = EventMoveLocal.find_by_name("local move event")
		Illness.infect(@pc, @disease)
		assert @pc.illnesses.size == 1
		assert_difference '@kingdom.illnesses.size', +1 do
			@direct, @comp, @msg = e.happens(@pc)
			@kingdom.reload
		end
	end
	
	test "local move event catch disease from kingdom" do
		e = EventMoveLocal.find_by_name("local move event")
		Illness.infect(@kingdom, @disease)
		assert @kingdom.illnesses.size == 1
		assert_difference '@pc.illnesses.size', +1 do
			@direct, @comp, @msg = e.happens(@pc)
			@pc.reload
		end
		assert @msg =~ /You don't feel so good/
	end
	
	test "create local move event" do
		e = EventMoveLocal.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1
		e.thing_id = Level.find(:first)
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
	
	test "throne event" do
		e = EventThrone.find_by_name("throne event")
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find(:first, :conditions => ['level = 0']).id
		
		direct, comp, msg = e.happens(@pc)
		assert comp == true
		
		@pc.present_kingdom.player_character.health.update_attribute(:HP, 0)
		
		direct, comp, msg = e.happens(@pc)
		assert comp.nil?
	end
	
end