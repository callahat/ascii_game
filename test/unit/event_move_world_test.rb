require 'test_helper'

class EventMoveWorldTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
	end
	
	test "world move event" do
		el = EventMoveWorld.find_by_name("world move event")
		direct, comp, msg = el.happens(@pc)
		assert @pc.in_kingdom.nil?
		assert @pc.kingdom_level.nil?
		assert comp == EVENT_COMPLETED
	end
	
	test "world move event when pc dead" do
		el = EventMoveWorld.find_by_name("world move event")
		
		#assert does not fail if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = el.happens(@pc)
		assert msg !~ /you are dead/
		
		assert @pc.in_kingdom.nil?
		assert @pc.kingdom_level.nil?
		assert comp == EVENT_COMPLETED
	end
	
	test "create world move event" do
		e = EventMoveWorld.new(@standard_new)
		assert e.valid?
		assert e.save!
	end
end