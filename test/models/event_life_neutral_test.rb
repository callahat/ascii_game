require 'test_helper'

class EventLifeNeutralTest < ActiveSupport::TestCase
	test "event life neutral rep number valid" do
		@event = EventLifeNeutral.new(:kingdom_id => Kingdom.first.id,
																	:player_id => Player.first.id,
																	:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
																	:name => 'Created event name',
																	:armed => 1,
																	:cost => 50)
		
		@event.valid?
		assert @event.errors.size == 0
		
		@event.event_rep_type = SpecialCode.get_code('event_rep_type','limited_per_char')
		@event.event_reps = nil
		@event.valid?
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = -1
		@event.valid?
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 9001
		@event.valid?
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 9000
		@event.valid?
		assert @event.errors.size == 0
		@event.errors.clear
		
		@event.event_rep_type = SpecialCode.get_code('event_rep_type','limited')
		@event.event_reps = nil
		@event.valid?
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = -1
		@event.valid?
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 9001
		@event.valid?
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 1
		@event.valid?
		assert @event.errors.size == 0
		@event.errors.clear
	end
	
	test "event life neutral sys gen event function" do
		assert e = EventLifeNeutral.sys_gen(:name => 'Test Sys Gen',
																				:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'))
		assert e.id.nil?
	end
	
	test "event life neutral sys gen and return saved event function" do
		assert e = EventLifeNeutral.sys_gen!(:name => 'Test Sys Gen',
																				:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'))
		assert e.id
	end
end
