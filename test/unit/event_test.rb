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
	end

	test "quest event" do
		eq = EventQuest.find_by_name("Quest event")
		direct, msg = eq.happens
		assert direct
		assert msg =~ /thunderous/
		assert eq.quest.name == "Quest One"
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
			@direct, @msg = ec.happens(@pc)
		end
		assert @direct.class == Hash
		assert @direct[:controller] == 'game/battle'
		
		#test where there are no living creatures
		ec.creature.update_attribute(:number_alive, 0)
		assert_difference 'Battle.count', +0 do
			@direct, @msg = ec.happens(PlayerCharacter.find(1))
		end
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
		direct, msg = ep.happens
		assert direct == true
		
		ep.player_character.health.update_attribute(:HP, 0)
		direct, msg = ep.happens
		assert direct.class == Hash
		assert msg =~ /mortal/
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
			direct,msg = ei.happens(@pc)
			@pc.items.reload
		end
		assert @pc.items.find(:first, :conditions => {:item_id => ei.thing_id}).quantity == 3
		
		assert_difference '@pc.items.size', +0 do
			direct,msg = ei.happens(@pc)
			@pc.items.reload
		end
		assert @pc.items.find(:first, :conditions => {:item_id => ei.thing_id}).quantity == 6
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
			direct,msg = ed.happens(@pc)
			assert direct == true
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 1
		assert @pc.health.wellness == SpecialCode.get_code('wellness','diseased')
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +0 do
			direct,msg = ed.happens(@pc)
			assert msg =~ /unhealthy/
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 1
		
		ed.flex = 1
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +5 do
			direct,msg = ed.happens(@pc)
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 0
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +0 do
			direct,msg = ed.happens(@pc)
			assert msg =~ /Nothing/
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 0
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
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
						direct,msg = es.happens(@pc)
						assert direct == true
						assert msg =~ /explaining/
						@pc.stat.reload
						@pc.health.reload
					end
				end
			end
		end
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
end