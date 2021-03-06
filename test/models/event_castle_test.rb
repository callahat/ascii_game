require 'test_helper'

class EventCastleTest < ActiveSupport::TestCase
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
		@disease = Disease.find_by_name("airbourne disease")
	end

	test "castle event" do
		e = EventCastle.find_by_name("castle event")
		direct, comp, msg = e.happens(@pc)

		assert_equal castle_game_court_path, direct
		assert_equal EVENT_COMPLETED, comp

		#assert does not fail if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert_no_match /you are dead/, msg
		assert_equal EVENT_COMPLETED, comp
	end

	test "create castle event" do
		e = EventCastle.new(@standard_new)
		assert e.valid?
		assert_equal 0, e.errors.full_messages.size
		assert e.save!
		assert_equal 0, e.price
		assert_equal 500, e.total_cost
	end
end
