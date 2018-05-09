require 'test_helper'

class PlayerCharacterKillerTest < ActiveSupport::TestCase
	test "pc killer test" do
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@enemy_pc = PlayerCharacter.find_by_name("Test King")
		
		assert @pc.player_character_killers.count(:conditions => ['killed_id = ?', @enemy_pc.id]) == 0
		PlayerCharacterKiller.create(:player_character_id => @pc.id, :killed_id => @enemy_pc.id)
		assert @pc.player_character_killers.count(:conditions => ['killed_id = ?', @enemy_pc.id]) == 1
	end
end
