require 'test_helper'

class EventSpawnKingdomTest < ActiveSupport::TestCase
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
		@kingdom = Kingdom.find(1)
	end

	test "spawn kingdom event" do
		e = EventSpawnKingdom.find_by_name("spawn kingdom event")
		direct, comp, msg = e.happens(@pc)
		assert direct[:action] == 'complete'
		assert msg =~ /not yet powerful enough/
		
		@kingdom.update_attribute(:player_character_id, @pc.id)
		@pc.update_attribute(:level, 42)
		direct, comp, msg = e.happens(@pc)
		assert direct[:action] == 'complete'
		assert msg =~ /already a king/, msg
		
		@kingdom.update_attribute(:player_character_id, 1)
		direct, comp, msg = e.happens(@pc)
		assert direct[:action] == 'spawn_kingdom'
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert msg =~ /you are dead/
	end
end
