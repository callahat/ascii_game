require 'test_helper'

class HealthTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "verify health fixtures loaded" do
    assert_equal 19, Health.count
    assert_equal 6, HealthPc.count
    assert_equal 12, HealthNpc.count
    [Npc, PlayerCharacter].each{|t| t.all.each{|c|
      assert c.health
    } }
  end
  
  test "adjusting pc and npc health for stats" do
    npc = Npc.find_by_name("Healthy Npc")
    pc = player_characters(:pc_one)
    stat = pc.stat
    assert npc.health.HP == 30
    assert npc.health.base_HP == 30
    assert npc.health.wellness == SpecialCode.get_code('wellness','alive')
    assert pc.health.HP == 0
    assert pc.health.base_HP == 0
    assert pc.health.MP == 0
    assert pc.health.base_MP == 0
    assert pc.health.wellness == SpecialCode.get_code('wellness','alive')
    
    #Check that modifying for level keeps the HP/MP difference from base the same
    pc.health.HP = 5
    pc.health.MP = 13
    npc.health.HP = 25
    
    assert pc.health.adjust_for_stats(stat, 1)
    assert npc.health.adjust_for_stats(stat, 1)
    
    [pc.health, npc.health].each{|h|
      Health.symbols{|sym|
        assert h[sym] != 0 } }
    
    assert pc.health.HP == pc.health.base_HP + 5
    assert pc.health.MP == pc.health.base_MP + 13
    assert npc.health.HP == npc.health.base_HP - 5
  end
  
  test "test health to symbol hash" do
    health = Health.first
    health_hash = Health.to_symbols_hash(health)
    assert health_hash.class == Hash
    Health.symbols.each{|sym|
      assert health_hash[sym] == health[sym] }
    assert health_pc = HealthPc.create(health_hash.merge(:owner_id => 1))
    assert health_npc = HealthNpc.create(health_hash.merge(:owner_id => 1))
    Health.symbols.each{|sym|
      assert health_npc[sym] == health[sym] }
    assert health_pc.destroy
    assert health_npc.destroy
  end
end
