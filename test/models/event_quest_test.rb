require 'test_helper'

class EventQuestTest < ActiveSupport::TestCase
  def setup
    @pc           = player_characters(:pc_one)
    @standard_new = {:kingdom_id     => Kingdom.first.id,
                     :player_id      => Player.first.id,
                     :event_rep_type => SpecialCode.get_code('event_rep_type', 'unlimited'),
                     :name           => 'Created event name',
                     :armed          => 1,
                     :cost           => 50}
  end

  test "quest event" do
    eq                = events(:quest_event_one)
    direct, comp, msg = eq.happens(@pc)
    assert_equal EVENT_COMPLETED, comp
    assert_equal "Quest One", eq.quest.name

    # assert fails if pc dead
    @pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness', 'dead'))
    direct, comp, msg = eq.happens(@pc)
    assert_match /you are dead/, msg
  end

  test "create quest event" do
    e = EventQuest.new(@standard_new)
    assert e.valid?
    assert e.errors.full_messages.size == 0
    e.text = "Quest text"
    assert e.valid?
    assert e.errors.full_messages.size == 0
    assert e.save!
    assert e.price == 0, e.price
    assert e.total_cost == 500, e.total_cost
  end
end