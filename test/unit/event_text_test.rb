require 'test_helper'

class EventTextTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.first.id,
											:player_id => Player.first.id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
	end

	test "text event" do
		eq = EventText.find_by_name("Text event")
		direct, comp, msg = eq.happens(@pc)
		assert comp == EVENT_COMPLETED
		assert msg =~ /thunderous/
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = eq.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create text event" do
		e = EventText.new(@standard_new)
		assert e.valid?
		assert e.errors.full_messages.size == 0
		e.text = "Text event text"
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
		assert e.price == 0, e.price
		assert e.total_cost == 500, e.total_cost
	end
end
