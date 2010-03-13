require 'test_helper'

class EventMoveRelativeTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
	end
	
	test "relative move event" do
		e = EventMoveRelative.find_by_name("relative move event")
		assert @pc.present_level.level == 0, @pc.present_level
		direct, comp, msg = e.happens(@pc)
		@pc.reload
		assert @pc.present_level.level == -1
		
		direct, comp, msg = e.happens(@pc)
		@pc.reload
		assert msg =~ /UNDER CONSTRUCTION/
		assert @pc.present_level.level == -1
	end
	
	test "when relative move pc dead" do
		e = EventMoveRelative.find_by_name("relative move event")
		assert @pc.present_level.level == 0, @pc.present_level
		
		#assert does not fail if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
	end
	
	test "relative move event when in world" do
		@pc.update_attribute(:in_kingdom, nil)
		@pc.update_attribute(:kingdom_level, nil)
		e = EventMoveRelative.find_by_name("relative move event")
		direct, comp, msg = e.happens(@pc)
		assert msg =~ /in the world/,msg
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
end