require 'test_helper'

class NonplayerCharacterKillerTest < ActiveSupport::TestCase
	test "npc killer test" do
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@npc = Npc.find_by_name("Healthy Npc")
		
		assert @pc.nonplayer_character_killers.where(npc: @npc).count == 0
		NonplayerCharacterKiller.create(player_character: @pc, npc: @npc)
		assert @pc.nonplayer_character_killers.where(npc: @npc).count == 1
	end
end
