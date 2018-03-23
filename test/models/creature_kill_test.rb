require 'test_helper'

class CreatureKillTest < ActiveSupport::TestCase
	test "creature kill test" do
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@wild_foo = Creature.find_by_name("Wild foo")
		
		assert @pc.creature_kills.where(creature: @wild_foo).count == 0
		assert @pc.creature_kills.where(creature: @wild_foo).first.nil?
		CreatureKill.log_kill(@pc.id, @wild_foo.id, 3)
		assert @pc.creature_kills.where(creature: @wild_foo).count == 1
		assert @pc.creature_kills.where(creature: @wild_foo).first.number == 3
	end
end
