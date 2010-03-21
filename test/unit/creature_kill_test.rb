require 'test_helper'

class CreatureKillTest < ActiveSupport::TestCase
	test "creature kill test" do
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@wild_foo = Creature.find_by_name("Wild foo")
		
		assert @pc.creature_kills.count(:conditions => ['creature_id = ?', @wild_foo.id]) == 0
		assert @pc.creature_kills.find(:first, :conditions => ['creature_id = ?', @wild_foo.id]).nil?
		CreatureKill.log_kill(@pc.id, @wild_foo.id, 3)
		assert @pc.creature_kills.count(:conditions => ['creature_id = ?', @wild_foo.id]) == 1
		assert @pc.creature_kills.find(:first, :conditions => ['creature_id = ?', @wild_foo.id]).number == 3
	end
end
