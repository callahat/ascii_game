require 'test_helper'

class EventSpawnKingdomTest < ActiveSupport::TestCase
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

	test "spawn kingdom event" do
		e = EventSpawnKingdom.find_by_name("spawn kingdom event")
		direct, comp, msg = e.happens(@pc)
		assert_equal complete_game_path, direct
		assert_match /not yet powerful enough/, msg
		
		@kingdom.update_attribute(:player_character_id, @pc.id)
		@pc.update_attribute(:level, 42)
		direct, comp, msg = e.happens(@pc)
		assert_equal complete_game_path, direct
		assert_match /already a king/, msg
		
		@kingdom.update_attribute(:player_character_id, 1)
		direct, comp, msg = e.happens(@pc)
		assert_equal spawn_kingdom_game_path, direct
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert_match /you are dead/, msg
	end
end
