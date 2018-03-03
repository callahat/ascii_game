require 'test_helper'

class EventNpcTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.first.id,
											:player_id => Player.first.id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
	end

	test "npc event" do
		e = EventNpc.find_by_name("Healthy Npc encounter")
		direct, comp, msg = e.happens(@pc)
		
		assert direct.class == Hash
		assert EVENT_COMPLETED
		
		#assert does not fail if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		assert EVENT_COMPLETED
	end
	
	test "create npc event" do
		e = EventNpc.new(@standard_new)
		assert !e.valid?
		assert_equal 2, e.errors.full_messages.size
		e.npc = Npc.first
		e.flex = LevelMap.first
		assert e.valid?
		assert_equal 0, e.errors.full_messages.size
		assert e.save!
		assert_equal 0, e.price
		assert_equal 500, e.total_cost
	end
end