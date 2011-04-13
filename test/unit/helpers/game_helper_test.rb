require 'test_helper'

class GameHelperTest < ActionView::TestCase
	def setup
		@creature = Creature.find_by_name("Wimp Monster")
		@level = Level.find(:first, :conditions =>['kingdom_id = ? and level = 0', 1])
		@world = World.find(:first)
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@pc[:in_kingdom] = 1
		@pc.present_world = @world
		@pc.present_level = @level
		@controller = GameController.new
		@request  = ActionController::TestRequest.new
		@response = ActionController::TestResponse.new
	end
	
	test "battle grid" do
		# get 'battle'
		battle, msg = Battle.new_creature_battle(@pc, @creature, 5, 5, @pc.in_kingdom)
		assert battle, msg
		output = battle_grid(battle)
		assert output =~ /Wimp Monsters/
	end

	test "draw the kingdom map" do
		# get 'main'
		output1 = draw_map(@level)
		assert output1 =~ /<table>/
		assert output1 !~ /<tr>North<\/td>/

		output2 = draw_kingdom_map(@level)
		assert output2 =~ /<table>/
		assert output2 !~ /<tr>North<\/td>/
		assert output1 == output2
	end
	
	test "draw the world map" do
		@pc.update_attributes(:in_kingdom => nil, :kingdom_level => nil)
		# get 'main'
		wmt = world_map_table([@world,0,0])
		output1 = draw_map([@world,0,0])
		assert output1 =~ /<table>/
		assert output1 !~ /<tr>North<\/td>/
		assert output1.index(wmt)
		
		output2 = draw_world_map([@world,0,0])
		assert output2 =~ /<table>/
		assert output2 !~ /<tr>North<\/td>/
		assert output1 == output2
	end
end
