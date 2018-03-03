require 'test_helper'

class CurrentEventTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@feature_ne = Feature.find_by_name("Feature Nothing")
		@feature_c = Feature.find_by_name("Creature Feature One")
		@feature_m = Feature.find_by_name("Feature Multi")
		@level = kingdoms(:kingdom_one).levels.find_by(level: 0)
		@world = World.find_by_name("WorldOne")

		#starting priority defaults at zero,btw
		@current_k_event = CurrentKingdomEvent.new(:player_character_id => @pc.id)
	end

	test "next event on feature with no events" do
		@location = @level.level_maps.find_by(xpos: 2, ypos: 2)
		@current_k_event.update_attribute(:location_id, @location.id)
		@next_pri, @next_ev = @current_k_event.next_event
		assert @next_pri.nil?
		assert @next_ev.nil?
	end
	
	test "next event on feature with one priority level one auto" do
		@location = @level.level_maps.find_by(xpos: 1, ypos: 1)
		@current_k_event.update_attribute(:location_id, @location.id)
		@next, @ev = @current_k_event.next_event

		assert @next == 1, @next.inspect
		assert @ev.class.base_class == Event, @ev.inspect
		
		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert @next.nil?
	end
	
	test "next event on feature with multiple priority levels" do
		@location = @level.level_maps.find_by(xpos: 0, ypos: 0)
		@current_k_event.update_attribute(:location_id, @location.id)
		@next, @ev = @current_k_event.next_event
		
		assert_equal 1, @next, @next.inspect
		assert_equal Array, @ev.class, @ev.inspect
		assert_equal 2, @ev.size, @ev.size
		
		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert_equal 2, @next, @next.inspect
		assert_equal Event, @ev.class.base_class, @ev.inspect

		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert_equal 3, @next, @next.inspect
		assert (@ev.class == Array && @ev.size == 1) || @ev.class.base_class == Event
		
		@current_k_event.update_attribute(:priority, @next)
		@next, @ev = @current_k_event.next_event
		
		assert_equal 7, @next, @next.inspect
		assert_equal Event, @ev.class.base_class, @ev.inspect
	end
	
	test "create new feature event based on pc location" do
		@kl = @level.level_maps.find_by(xpos: 2, ypos: 2)
		@wm = @world.world_maps.find_by(xpos: 1, ypos: 1, bigxpos: 0, bigypos: 0)
		
		@current_loc_event = CurrentEvent.make_new(@pc, @kl.id)
		assert_equal CurrentKingdomEvent, @current_loc_event.class
		assert_equal @kl.id, @current_loc_event.location_id
		assert_equal @pc.id, @current_loc_event.player_character_id
		
		@pc.update_attribute(:in_kingdom,nil)
		@pc.update_attribute(:kingdom_level,nil)
		
		@current_w_event = CurrentEvent.make_new(@pc, @wm.id)
		assert_equal CurrentWorldEvent, @current_w_event.class
		assert_equal @wm.id, @current_w_event.location_id, @current_w_event.location.inspect
		assert_equal @pc.id, @current_w_event.player_character_id
	end
	
	test "current event complete" do
		DoneEvent.destroy_all
		q = Quest.find_by_name("Quest One")
		joined, msg = LogQuest.join_quest(@pc, q.id)    
		assert joined

		@kl = @level.level_maps.find_by(xpos: 0, ypos: 0)
		@current_loc_event = CurrentEvent.make_new(@pc, @kl.id)
		assert @current_loc_event.class == CurrentKingdomEvent
		
		@next, @choices = @current_loc_event.next_event
		
		@current_loc_event.update_attributes(:event_id => @choices.first.id, :priority => @next)
		
		@current_loc_event.update_attribute(:completed, EVENT_INPROGRESS)
		@next, @it = @current_loc_event.complete
		assert @next == @current_loc_event.priority
		assert @it == @current_loc_event.event
		
		@current_loc_event.update_attribute(:completed, EVENT_FAILED)
		@next, @it = @current_loc_event.complete
		assert @next.nil?
		assert @it.nil?
		
		@current_loc_event.update_attribute(:completed, EVENT_COMPLETED)
		@next, @it = @current_loc_event.complete
		assert @next == 2, @next.inspect
		assert @it.class.base_class == Event, @it.inspect
		
		@current_loc_event.update_attribute(:priority, 4)
		@current_loc_event.update_attribute(:completed, EVENT_SKIPPED)
		@next, @it = @current_loc_event.complete
		assert @next == 5, @next.inspect
		assert @it.class.base_class == Event, @it.inspect
		
		#QuestExplore
		@pc.log_quests.find_by_quest_id(q.id).explores.first.update_attribute(:detail, @it.id)
		#Test loging of quest, done events
		assert @pc.log_quests.find_by_quest_id(q.id).reqs.size == 6
		#@current_loc_event.update_attributes(:event_id => @it.id, :priority => @next)
		@current_loc_event.update_attributes(:event => @it, :priority => @next)
		@current_loc_event.update_attribute(:completed, EVENT_COMPLETED)
		@next, @it = @current_loc_event.complete
		assert @next == 7
		
		@de = @pc.done_local_events.find_by(event_id: @current_loc_event.event_id,
																				location_id: @current_loc_event.location_id)
		@pc.log_quests.find_by_quest_id(q.id).reqs.reload
		assert_equal 5, @pc.log_quests.find_by_quest_id(q.id).reqs.size
		assert @de
		assert @de.class == DoneLocalEvent
	end
end
