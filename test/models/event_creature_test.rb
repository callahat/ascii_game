require 'test_helper'

class EventCreatureTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @pc = PlayerCharacter.find_by_name("Test PC One")
    @standard_new = {:kingdom_id => Kingdom.first.id,
                      :player_id => Player.first.id,
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
    assert_equal battle_game_battle_path, @direct
    assert_equal EVENT_INPROGRESS, @comp
    
    #test where there are no living creatures
    ec.creature.update_attribute(:number_alive, 0)
    assert_difference 'Battle.count', +0 do
      @direct, @comp, @msg = ec.happens(player_characters(:pc_one))
    end
    ec.creature.update_attribute(:number_alive, 1000)
    assert_equal EVENT_COMPLETED, @comp
    
    #assert fails if pc dead
    @pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
    direct, comp, msg = ec.happens(@pc)
    assert_match /you are dead/, msg
    assert_equal EVENT_FAILED, comp
  end
  
  test "create creature event" do
    e = EventCreature.new(@standard_new.merge(:flex => "0;0"))
    assert !e.valid?
    assert_equal 3, e.errors.full_messages.size
    e.creature = Creature.first
    assert !e.valid?
    assert_equal 2, e.errors.full_messages.size
    e.flex = "4;9"
    assert e.valid?,e.errors.full_messages.inspect
    assert_equal 0, e.errors.full_messages.size
    assert e.save!
    assert e.price > 0, e.price.inspect
    assert e.total_cost > 500, e.total_cost.inspect
  end
end
