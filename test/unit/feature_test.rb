require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@feature_ne = Feature.find_by_name("Feature Nothing")
		@feature_c = Feature.find_by_name("Creature Feature One")
		@feature_m = Feature.find_by_name("Feature Multi")
		@level = Level.where(["kingdom_id = 1 and level = 0"] ).first
		@location = @level.level_maps.where(['xpos = 0 and ypos = 0']).first
	end
	
	test "available events" do
		#feature without any events will not have any
		@choices, @autos = @feature_ne.available_events(1, @location, @pc.id)
		assert_equal 0, @choices.size
		assert_equal 0, @autos.size
		
		#feaure with one priority level
		@choices, @autos = @feature_c.available_events(1, @location, @pc.id)
		assert_equal 0, @choices.size
		assert_equal 1, @autos.size
		
		@choices, @autos = @feature_c.available_events(3, @location, @pc.id)
		assert_equal 0, @choices.size
		assert_equal 0, @autos.size
		
		#feature with many priority levels and many events at each priority level
		@choices, @autos = @feature_m.available_events(1, @location, @pc.id)
		assert_equal 2, @choices.size
		assert_equal 0, @autos.size
		
		@choices, @autos = @feature_m.available_events(2, @location, @pc.id)
		assert_equal 0, @choices.size
		assert_equal 2, @autos.size
		
		@choices, @autos = @feature_m.available_events(3, @location, @pc.id)
		assert_equal 1, @choices.size
		assert_equal 2, @autos.size
		
		#one event at priority with zero chance
		@choices, @autos = @feature_m.available_events(4, @location, @pc.id)
		assert_equal 0, @choices.size
		assert_equal 0, @autos.size
		
		#one event thats been done at this place
		@choices, @autos = @feature_m.available_events(5, @location, @pc.id)
		assert_equal 0, @choices.size
		assert_equal 0, @autos.size
		
		@choices, @autos = @feature_m.available_events(7, @location, @pc.id)
		assert_equal 0, @choices.size
		assert_equal 1, @autos.size
	end
	
	test "next priority" do
		assert @feature_ne.next_priority(1).nil?
		assert @feature_c.next_priority(0) == 1
		assert @feature_c.next_priority(1).nil?
		assert @feature_m.next_priority(0) == 1
		assert @feature_m.next_priority(1) == 2
		assert @feature_m.next_priority(2) == 3
		assert @feature_m.next_priority(3) == 4
		assert @feature_m.next_priority(4) == 5
		assert @feature_m.next_priority(5) == 7
		assert @feature_m.next_priority(6) == 7
		assert @feature_m.next_priority(7).nil?
	end
end
