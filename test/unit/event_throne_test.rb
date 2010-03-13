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
	end
	
	test "throne event" do
		e = EventThrone.find_by_name("throne event")
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.find(:first, :conditions => ['level = 0']).id
		
		direct, comp, msg = e.happens(@pc)
		assert comp == true
		
		@pc.present_kingdom.player_character.health.update_attribute(:HP, 0)
		
		direct, comp, msg = e.happens(@pc)
		assert comp.nil?
		
		#assert does not fail if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		assert comp.nil?
	end
end