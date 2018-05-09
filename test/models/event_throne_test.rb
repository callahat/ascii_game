require 'test_helper'

class EventThroneTest < ActiveSupport::TestCase
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
		@level = Level.find_by(kingdom_id: 1, level: 0)
	end
	
	test "throne event" do
		e = events(:throne_event)
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find_by(level: 0).id
		
		direct, comp, msg = e.happens(@pc)
		assert comp == EVENT_COMPLETED
		
		@pc.present_kingdom.player_character.health.update_attribute(:HP, 0)
		
		direct, comp, msg = e.happens(@pc)
		assert EVENT_COMPLETED
		
		#assert does not fail if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		assert EVENT_COMPLETED
	end
	
	test "throne event completes" do
		e = events(:throne_event)
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find_by(level: 0).id
		e.completes(@pc)
		
		#king not killed by pc
		assert @kingdom.player_character_id != @pc.id
		
		# #assert timeout, not that important; leave commented out
		# PlayerCharacterKiller.create(:player_character_id => @pc.id, :killed_id => @kingdom.player_character_id)
		# sleep 11*60
		# e.completes(@pc)
		# assert @kingdom.player_character_id != @pc.id

		PlayerCharacterKiller.create(:player_character_id => @pc.id, :killed_id => @kingdom.player_character_id)
		e.completes(@pc)
		@kingdom.reload
		assert_equal @kingdom.player_character_id, @pc.id
		assert_equal 0, e.price
		assert_equal 500, e.total_cost
	end
end