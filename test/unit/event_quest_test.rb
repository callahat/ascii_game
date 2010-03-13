require 'test_helper'

class EventQuestTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
	end

	test "quest event" do
		eq = EventQuest.find_by_name("Quest event")
		direct, comp, msg = eq.happens(@pc)
		assert comp == true
		assert msg =~ /thunderous/
		assert eq.quest.name == "Quest One"
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = eq.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create quest event" do
		e = EventQuest.new(@standard_new)
		assert e.valid?
		assert e.errors.full_messages.size == 0
		e.text = "Quest text"
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
end