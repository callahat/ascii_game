require 'test_helper'

class EventTest < ActiveSupport::TestCase
	test "rep number valid" do
		@event = Event.new(:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50)
		
		@event.validate
		assert @event.errors.size == 0
		
		@event.event_rep_type = SpecialCode.get_code('event_rep_type','limited_per_char')
		@event.event_reps = nil
		@event.validate
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = -1
		@event.validate
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 9001
		@event.validate
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 9000
		@event.validate
		assert @event.errors.size == 0
		@event.errors.clear
		
		@event.event_rep_type = SpecialCode.get_code('event_rep_type','limited')
		@event.event_reps = nil
		@event.validate
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = -1
		@event.validate
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 9001
		@event.validate
		assert @event.errors.size == 1
		@event.errors.clear
		@event.event_reps = 1
		@event.validate
		assert @event.errors.size == 0
		@event.errors.clear
	end
	
	test "get event types" do
		assert Event.get_event_types(false)
		assert Event.get_event_types(true)
	end
	
	test "sys gen event function" do
		assert e = Event.sys_gen(:name => 'Test Sys Gen',
															:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'))
		assert e.id.nil?
	end
	
	test "sys gen and return saved event function" do
		assert e = Event.sys_gen!(:name => 'Test Sys Gen',
															:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'))
		assert e.id
	end
end