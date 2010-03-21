require 'test_helper'

class EventCreatureTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
	end
	
	test "creature event" do
		ec = EventCreature.find_by_name("Weak Monster encounter")
		assert ec.creature.name == "Wimp Monster"
		assert_difference 'Battle.count', +1 do
			@direct, @comp, @msg = ec.happens(@pc)
		end
		assert @direct.class == Hash
		assert @direct[:controller] == 'game/battle'
		assert @comp == EVENT_INPROGRESS
		
		#test where there are no living creatures
		ec.creature.update_attribute(:number_alive, 0)
		assert_difference 'Battle.count', +0 do
			@direct, @comp, @msg = ec.happens(PlayerCharacter.find(1))
		end
		ec.creature.update_attribute(:number_alive, 1000)
		assert @comp == EVENT_COMPLETED
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ec.happens(@pc)
		assert msg =~ /you are dead/
		assert comp == EVENT_FAILED
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
end