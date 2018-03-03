require 'test_helper'

class KingdomTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@feature_k = Feature.find_by_name("Feature Nothing")
		@kingdom = Kingdom.find_by_name("HealthyTestKingdom")
		@world_map = WorldMap.where(xpos: 1, ypos: 1, bigxpos: 0, bigypos: -1).last
	end
	
	test "associations" do
		assert @kingdom.live_npcs.size == @kingdom.merchants.size + @kingdom.guards.size
	end
	
	test "pay tax" do
		assert_difference '@kingdom.gold', +500 do
			assert Kingdom.pay_tax(500, @kingdom.id)
			@kingdom.reload
		end
	end
	
	test "reserve peasants" do
		assert_difference '@kingdom.num_peasants', -300 do
			assert @kingdom.reserve_peasants(500) == 300
			@kingdom.reload
		end
	end
	
	test "change king" do
		assert @kingdom.player_character_id != @pc.id
		assert @kingdom.change_king(@pc)
		@kingdom.reload
		assert @kingdom.player_character_id == @pc.id
	end
	
	test "can spawn" do
		assert Kingdom.cannot_spawn(@pc) =~ /not yet powerful/
		@pc.update_attribute(:level, 50)
		@kingdom.player_character.update_attribute(:level, 50)
		assert Kingdom.cannot_spawn(@pc).nil?
		assert Kingdom.cannot_spawn(@kingdom.player_character) =~ /already a king/
	end
	
	test "build foundation and the rest" do
		@new_kingdom = Kingdom.build_foundation(@pc, "", @world_map)
		assert !@new_kingdom.valid?
		@new_kingdom = Kingdom.build_foundation(@pc, "HealthyTestKingdom", @world_map)
		assert !@new_kingdom.valid?
		@pc.update_attribute(:level, 50)
		assert_difference 'Kingdom.count', +1 do
			@new_kingdom = Kingdom.build_foundation(@pc, "New Unused Kingdom Name", @world_map)
			assert @new_kingdom[0].nil?
			assert @pc.id == @new_kingdom.player_character_id
		end
		assert_difference 'WorldMap.count', +1 do
			assert @new_kingdom.build_the_rest(@world_map)
			assert @new_kingdom.kingdom_entry
		end
	end
	
	test "spawn kingdom" do
		@pc.update_attribute(:level, 50)
		@new_kingdom = Kingdom.spawn_new(@pc, "HealthyTestKingdom", @world_map)
		assert !@new_kingdom[0].valid?
		assert_difference 'WorldMap.count', +1 do
			assert_difference 'Kingdom.count', +1 do
				@new_kingdom = Kingdom.spawn_new(@pc, "NewName", @world_map)
				assert @new_kingdom[0].nil?
			end
		end
	end
end