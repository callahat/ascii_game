require 'test_helper'

class NonplayerCharacterKillerTest < ActiveSupport::TestCase
	test "npc killer test" do
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@npc = Npc.find_by_name("Healthy Npc")
		
		assert @pc.nonplayer_character_killers.count(:conditions => ['npc_id = ?', @npc.id]) == 0
		NonplayerCharacterKiller.create(:player_character_id => @pc.id, :npc_id => @npc.id)
		assert @pc.nonplayer_character_killers.count(:conditions => ['npc_id = ?', @npc.id]) == 1
	end
end
