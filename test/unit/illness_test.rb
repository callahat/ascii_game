require 'test_helper'

class IllnessTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "verify illness fixture loaded" do
    assert Illness.count == 7
    assert Infection.count == 4
    assert NpcDisease.count == 2
    assert Pandemic.count == 1
  end
  
  test "infect" do
    @pc = PlayerCharacter.find_by_name("sick pc")
    @disease = Disease.find_by_name("NewInfection")
    assert @pc.illnesses.size == 4, @pc.illnesses.size
		pcstr = @pc.stat.str
		basepcstr = @pc.base_stat.str
    assert Illness.infect(@pc, @disease)
    assert @pc.illnesses.size == 5
    assert @pc.stat.str == pcstr - 5
    assert @pc.base_stat.str == basepcstr
    
    #Can't infect more than once with same disease
    assert !Illness.infect(@pc, @disease)
    assert @pc.illnesses.size == 5
    
    @pc2 = PlayerCharacter.find_by_name("Test PC One")
    assert @pc2.health.wellness == SpecialCode.get_code('wellness', 'alive')
    assert @pc2.illnesses.size == 0
    assert Illness.infect(@pc2, @disease)
    assert @pc2.health.wellness == SpecialCode.get_code('wellness', 'diseased'), @pc2.health.wellness.to_s + " " + SpecialCode.get_code('wellness', 'diseased').to_s
    assert @pc2.illnesses.size == 1
  end
  
  test "infect npc" do
    @npc = Npc.find_by_name("Sick NPC")
    @disease = Disease.find_by_name("NewInfection")
    assert @npc.illnesses.size == 2
    assert Illness.infect(@npc, @disease)
    assert @npc.illnesses.size == 3
    
    #Can't infect more than once with same disease
    assert !Illness.infect(@npc, @disease)
    assert @npc.illnesses.size == 3
    
    @npc2 = Npc.find_by_name("Healthy Npc")
    assert @npc2.illnesses.size == 0
    assert @npc2.health.wellness == SpecialCode.get_code('wellness', 'alive')
    assert Illness.infect(@npc2, @disease)
    assert @npc2.illnesses.size == 1
    assert @npc2.health.wellness == SpecialCode.get_code('wellness', 'diseased')
  end
  
  test "infect kingdom" do
    @kingdom = Kingdom.find_by_name("SickTestKingdom")
    @disease = Disease.find_by_name("NewInfection")
    assert @kingdom.illnesses.size == 1
    assert @kingdom.pandemics.size == 1
    assert Illness.infect(@kingdom, @disease)
    assert @kingdom.illnesses.size == 2
    
    #Can't infect more than once with same disease
    assert !Illness.infect(@kingdom, @disease)
    assert @kingdom.illnesses.size == 2
  end
  
  test "infect others" do
    @pc = PlayerCharacter.find_by_name("sick pc")
    @healthy_pc = PlayerCharacter.find_by_name("Test PC One")
    @npc = Npc.find_by_name("Sick NPC")
    @kingdom = Kingdom.find_by_name("SickTestKingdom")
    
    assert @pc.illnesses.size == 4
    assert @npc.illnesses.size == 2
    assert @kingdom.illnesses.size == 1
    assert @healthy_pc.illnesses.size == 0
    
    #pc -> npc
    assert Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method', 'contact'))
    assert @npc.illnesses.size == 3
    assert @pc.illnesses.size == 4
    assert Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method', 'luminiferous ether'))
    assert @npc.illnesses.size == 4
    assert !Illness.spread(@pc, @npc, SpecialCode.get_code('trans_method', 'air'))
    assert @npc.illnesses.size == 4
    
    #npc -> pc
    assert Illness.spread(@npc, @pc, SpecialCode.get_code('trans_method', 'air'))
    assert @pc.illnesses.size == 5
    
    #npc -> kingdom
    assert Illness.spread(@npc, @kingdom, SpecialCode.get_code('trans_method', 'air'))
    assert @kingdom.illnesses.size == 2
    assert @npc.illnesses.size == 4
    
    #kingdom -> pc
    assert @healthy_pc.illnesses.size == 0
    assert Illness.spread(@kingdom, @healthy_pc, SpecialCode.get_code('trans_method', 'air'))
    assert @healthy_pc.illnesses.size == 2
    
    #pc -> pc
    assert Illness.spread(@pc, @healthy_pc, SpecialCode.get_code('trans_method', 'fluid'))
    assert @healthy_pc.illnesses.size == 3
    assert Illness.spread(@pc, @healthy_pc, SpecialCode.get_code('trans_method', 'contact'))
    assert @healthy_pc.illnesses.size == 4
  end
  
  test "pagination" do
    assert Infection.get_page(1).size == 4
    assert NpcDisease.get_page(1).size == 2
    assert Pandemic.get_page(1).size == 1
  end
end
