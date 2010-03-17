require 'test_helper'

class CurrentEventTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@feature_ne = Feature.find_by_name("Feature Nothing")
		@feature_c = Feature.find_by_name("Creature Feature One")
		@feature_m = Feature.find_by_name("Feature Multi")
		@level = Level.find(:first, :conditions => ["kingdom_id = 1 and level = 0"] )

		#starting priority defaults at zero,btw
		@current_k_event = CurrentKingdomEvent.new(:player_character_id => @pc.id)
	end

	#test "next event on feature with no events" do
	#	@location = @level.level_maps.find(:first, :conditions => ['xpos = 2 and ypos = 2'])
	#	@current_k_event.update_attribute(:location_id, @location.id)
	#	@next_pri, @next_ev = @current_k_event.next_event
	#	assert @next_pri.nil?
	#	assert @next_ev.nil?
	#end
	
	test "next event on feature with one priority level one auto" do
		@location = @level.level_maps.find(:first, :conditions => ['xpos = 1 and ypos = 1'])
		@current_k_event.update_attribute(:location_id, @location.id)
		@next, @ev = @current_k_event.next_event

		assert @next == 1, @next
		assert @ev.class.base_class == Event, @ev.inspect
		
		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert @next.nil?
	end
	
	test "next event on feature with multiple priority levels" do
		@location = @level.level_maps.find(:first, :conditions => ['xpos = 0 and ypos = 0'])
		@current_k_event.update_attribute(:location_id, @location.id)
		@next, @ev = @current_k_event.next_event
		
		assert @next == 1, @next
		assert @ev.class == Array, @ev.inspect
		assert @ev.size == 2, @ev.size
		
		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert @next == 2, @next
		assert @ev.class.base_class == Event, @ev.inspect
		
		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert @next == 3, @next
		assert (@ev.class == Array && @ev.size == 1) || @ev.class.base_class == Event
		
		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert @next == 7, @next
		assert @ev.class.base_class == Event, @ev.inspect
	end
end
