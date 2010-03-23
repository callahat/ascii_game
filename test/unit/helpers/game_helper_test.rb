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
		get 'battle'
		battle, msg = Battle.new_creature_battle(@pc, @creature, 5, 5, @pc.in_kingdom)
		assert battle, msg
		output = battle_grid(battle)
		assert output =~ /Wimp Monsters/
	end

	test "draw kingdom map" do
		get 'feature'
		output = draw_map(@level)
		assert output =~ /<table>/
		assert output !~ /<tr>North<\/td>/
		
		output2 = draw_kingdom_map(@level)
		assert output2 =~ /<table>/
		assert output2 !~ /<tr>North<\/td>/
		assert output == output2
	end
	
	test "draw world map" do
		@pc.update_attributes(:in_kingdom => nil, :kingdom_level => nil)
		get 'feature'
		wmt = world_map_table([@world,0,0])
		
		output = draw_map([@world,0,0])
		assert output =~ /<table>/
		assert output !~ /<tr>North<\/td>/
		assert output.index(wmt)
		
		output2 = draw_world_map([@world,0,0])
		assert output2 =~ /<table>/
		assert output2 !~ /<tr>North<\/td>/
		assert output == output2
	end
end
