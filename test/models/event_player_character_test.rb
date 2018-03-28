require 'test_helper'

class EventPlayerCharacterTest < ActiveSupport::TestCase
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

	test "pc event" do
		ep = EventPlayerCharacter.find_by_name("Sick PC encounter")
		assert ep.player_character.name == "sick pc"
		direct, comp, msg = ep.happens(@pc)
		assert_equal EVENT_COMPLETED, comp
		
		ep.player_character.health.update_attribute(:HP, 0)
		direct, comp, msg = ep.happens(@pc)
		assert_equal complete_game_path, direct
		assert_match /mortal/, msg
		ep.player_character.health.update_attribute(:HP, 70)
		
		#assert not fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ep.happens(@pc)
		assert_equal EVENT_COMPLETED, comp
	end
	
	test "create pc event" do
		e = EventPlayerCharacter.new(@standard_new)
		assert !e.valid?, e.errors.full_messages.inspect
		assert_equal 1, e.errors.full_messages.size, e.errors.full_messages.inspect
		e.player_character = PlayerCharacter.first
		assert e.valid?, e.errors.full_messages.inspect
		assert_equal 0, e.errors.full_messages.size, e.errors.full_messages.inspect
		assert e.save!
		assert_equal 0, e.price
		assert_equal 500, e.total_cost
	end
end