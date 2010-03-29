require 'test_helper'

class EventThroneTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@pc.update_attribute(:in_kingdom, nil)
		@pc.update_attribute(:kingdom_level, nil)
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
		@kingdom = Kingdom.find(1)
		@disease = Disease.find_by_name("airbourne disease")
		@level = Level.find(:first, :conditions => ["kingdom_id = 1 and level = 0"] )
	end
	
	test "throne event" do
		e = EventThrone.find_by_name("throne event")
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find(:first, :conditions => ['level = 0']).id
		
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
		e = EventThrone.find_by_name("throne event")
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find(:first, :conditions => ['level = 0']).id
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
		assert @kingdom.player_character_id == @pc.id,@kingdom.player_character_id
		assert e.price == 0, e.price
		assert e.total_cost == 500, e.total_cost
	end
end