require 'test_helper'

class EventStormGateTest < ActiveSupport::TestCase
	include Rails.application.routes.url_helpers

	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@pc.update_attribute(:in_kingdom, nil)
		@pc.update_attribute(:kingdom_level, nil)
		@standard_new = {:kingdom_id => Kingdom.first.id,
											:player_id => Player.first.id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
		@kingdom = kingdoms(:kingdom_one)
	end

	test "storm gate" do
		es = EventStormGate.find_by_name("Storm Kingdom 1 Gate event")
		assert_difference 'Battle.count', +1 do
			@direct, @comp, @msg = es.happens(@pc)
		end
		assert_match battle_game_battle_path, @direct
		assert_equal EVENT_INPROGRESS, @comp
		
		#test where there are no guards
		es.level.kingdom.npcs.destroy_all
		assert_difference 'Battle.count', +0 do
			@direct, @comp, @msg = es.happens(player_characters(:pc_one))
		end
		assert_equal EVENT_COMPLETED, @comp
		assert_match /no resistance/, @msg
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = es.happens(@pc)
		assert_match /you are dead/, msg
		assert_equal EVENT_FAILED, comp
	end
	
	test "storm gate completes" do
		es = EventStormGate.find_by_name("Storm Kingdom 1 Gate event")
		
		assert @pc.in_kingdom.nil?
		assert @pc.kingdom_level.nil?
		es.completes(@pc)
		assert @pc.in_kingdom
		assert @pc.kingdom_level
	end
	
	test "create storm gate" do
		e = EventStormGate.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1, e.errors.full_messages.inspect
		e.level = Level.first
		assert e.valid?,e.errors.full_messages.inspect
		assert_equal 0, e.errors.full_messages.size
		assert e.save!
		assert_equal 0, e.price
		assert_equal 500, e.total_cost
	end
end
