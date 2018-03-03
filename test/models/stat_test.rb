require 'test_helper'

class HealthTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  # Replace this with your real tests.
  test "verify stat fixtures loaded" do
    assert_equal 50, Stat.count
    assert_equal 6, StatPc.count
    assert_equal 6, StatPcBase.count
    assert_equal 6, StatPcTrn.count
    assert_equal 6, StatDisease.count
    assert_equal 2, StatRace.count
    assert_equal 2, StatCClass.count
    assert_equal 12, StatNpc.count
    
    PlayerCharacter.all.each{|pc|
      assert pc.stat
      assert pc.base_stat
      assert pc.trn_stat }
    [Disease, Npc].each{|t| t.all.each{|c|
      assert c.stat, c.inspect
    } }
    [Race, CClass].each{|t| t.all.each{|c|
      assert c.stat
      assert c.level_zero
    } }
  end
  
  test "valid for level zero function" do
    stat = StatPc.new(:owner_id => 555)  #id doesnt really matter for this test
    stat[:str] = 40
    stat[:con] = -4
    assert !stat.valid_for_level_zero
    assert !stat.save_level_zero
    assert stat.errors.full_messages.size > 0
    stat.errors.clear
    
    stat[:con] = 90
    assert !stat.valid_for_level_zero
    assert !stat.save_level_zero
    
    stat.errors.clear
    stat[:con] = 10
    assert stat.valid_for_level_zero
    assert stat.save_level_zero
  end
  
  test "test stat to symbol hash" do
    stat = stats(:one_pc_stat)
    stat_hash = Stat.to_symbols_hash(stat)
    assert stat_hash.class == Hash
    stat_hash[:owner_id] = 555
    Health.symbols.each{|sym|
      assert stat_hash[sym] == stat[sym] }
    assert StatPc.create(stat_hash)
    assert StatNpc.create(stat_hash)
  end
  
  test "symbols" do
    syms = Stat.symbols
    assert syms.size == 7
    assert syms.index(:con)
    assert syms.index(:dam)
    assert syms.index(:dex)
    assert syms.index(:dfn)
    assert syms.index(:int)
    assert syms.index(:mag)
    assert syms.index(:str)
  end
  
  test "stat additions" do
    #There are only two StatNpc entries, with all attribs 10
    s1 = stats(:npc_one_stat)
    s2 = stats(:npc_one_stat).dup
    assert s3 = Stat.add_stats(s1,s2)
    Stat.symbols.each{|sym|
      assert s3[sym] == 20
      assert s3[sym] == s1[sym] + s2[sym] }

    s1_old = s1.dup
    s2_old = s2.dup
    assert s1.add_stats(s2)
    Stat.symbols.each{|sym|
      assert s1[sym] == 20
      assert s1[sym] == s1_old[sym] + s2[sym], s1[sym].to_s + " " + s1_old[sym].to_s + " " + s2[sym].to_s
      assert s2[sym] == s2_old[sym] }
  end
  
  test "stat subtractions" do
    s1 = stats(:npc_one_stat)
    s2 = stats(:air_disease_stat)
    Stat.symbols.each{|sym|
      assert s1[sym] == 10
      assert s2[sym] == 5 }
    
    assert s1.subtract_stats(s2)
    Stat.symbols.each{|sym|
      assert s1[sym] == 5
      assert s2[sym] == 5 }
  end
  
  test "to level" do
    rstat = stats(:race_one_stat)
    rstat_old = rstat.clone
    assert rstat.to_level(10)
    Stat.symbols.each{|sym|
      assert rstat[sym] >= rstat_old[sym] }
  end
  
  test "valid distrib" do
    stat = Stat.new
    stat[:mag] = -9
    assert !stat.valid_distrib(5)
    
    stat.errors.clear
    stat[:mag] = 4
    stat[:str] = 20
    
    assert !stat.valid_distrib(5)
    
    stat.errors.clear
    stat[:str] = 0
    stat[:dex] = 3
    
    assert stat.valid_distrib(7)
    assert stat.valid_distrib(10)
  end
  
  test "sum points and est level" do
    s1 = stats(:one_pc_stat)
    s2 = stats(:air_disease_stat)
    assert s1.sum_points == 70
    assert s2.sum_points == 35
    
    s3 = StatCreature.new
    Stat.symbols.each{|sym|
      s3[sym] = 30 }
    assert s3.est_level == 35
  end
  
  test "exp needed" do
    c1 = CClass.find_by_name("Class One").level_zero.dup
    c2 = CClass.find_by_name("Class Two").level_zero.dup
    r1 = Race.find_by_name("Race One").level_zero.dup
    r2 = Race.find_by_name("Race Two").level_zero.dup
    
    assert c1.exp_for_level(2) > c1.exp_for_level(1)
    assert r1.exp_for_level(5) > r1.exp_for_level(4)
    
    assert c1.exp_for_level(5) == c1.exp_for_level(5)
    assert c1.total_exp_for_level(5) == c1.exp_for_level(5)
    
    assert c2.exp_for_level(5) == c2.exp_for_level(5)
    assert c2.total_exp_for_level(5) > c2.exp_for_level(5)
    
    assert r1.exp_for_level(25) == r1.exp_for_level(25)
    assert r1.total_exp_for_level(25) == r1.exp_for_level(25)
    
    assert r2.exp_for_level(25) == r2.exp_for_level(25)
    assert r2.total_exp_for_level(25) > r2.exp_for_level(25)
  end
end
