require 'test_helper'

class EventMoveRelativeTest < ActiveSupport::TestCase
    def setup
        @pc = PlayerCharacter.find_by_name("Test PC One")
        @standard_new = {:kingdom_id => Kingdom.first.id,
                                            :player_id => Player.first.id,
                                            :event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
                                            :name => 'Created event name',
                                            :armed => 1,
                                            :cost => 50}
    end

    test "relative move event" do
        e = EventMoveRelative.find_by_name("relative move event")
        assert_equal 0, @pc.present_level.level, @pc.present_level
        direct, comp, msg = e.happens(@pc)
        @pc.reload
        assert_equal EVENT_COMPLETED, comp
        assert_equal "Moved to level -1", msg
        assert_equal -1, @pc.present_level.reload.level

        direct, comp, msg = e.happens(@pc)
        @pc.reload
        assert msg =~ /UNDER CONSTRUCTION/
        assert @pc.present_level.level == -1
        assert comp == EVENT_COMPLETED
    end

    test "when relative move pc dead" do
        e = EventMoveRelative.find_by_name("relative move event")
        assert @pc.present_level.level == 0, @pc.present_level.inspect

        #assert does not fail if pc dead
        @pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
        direct, comp, msg = e.happens(@pc)
        assert msg !~ /you are dead/
        assert comp == EVENT_COMPLETED
    end

    test "relative move event when in world" do
        @pc.update_attribute(:in_kingdom, nil)
        @pc.update_attribute(:kingdom_level, nil)
        e = EventMoveRelative.find_by_name("relative move event")
        direct, comp, msg = e.happens(@pc)
        assert msg =~ /in the world/,msg
        assert comp == EVENT_COMPLETED
    end

    test "create relative move event" do
        e = EventMoveRelative.new(@standard_new)
        assert !e.valid?
        assert_equal 1, e.errors.full_messages.size
        e.flex = '1'
        assert e.valid?
        assert_equal 0, e.errors.full_messages.size
        assert e.save!
        assert_equal 0, e.price
        assert_equal 500, e.total_cost
    end
end
