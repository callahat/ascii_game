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
		assert_equal 4, @pc.illnesses.size
		pcstr = @pc.stat.str
		basepcstr = @pc.base_stat.str
		assert Illness.infect(@pc, @disease)
		assert_equal 5, @pc.illnesses.size
		assert_equal pcstr - 5, @pc.stat.str
		assert_equal basepcstr, @pc.base_stat.str
		
		#Can't infect more than once with same disease
		assert !Illness.infect(@pc, @disease)
		assert_equal 5, @pc.illnesses.size
		
		@pc2 = PlayerCharacter.find_by_name("Test PC One")
		assert SpecialCode.get_code('wellness', 'alive'), @pc2.health.wellness.inspect
		assert_equal 0, @pc2.illnesses.size
		assert Illness.infect(@pc2, @disease)
		assert_equal SpecialCode.get_code('wellness', 'diseased'), @pc2.health.wellness, @pc2.health.wellness.to_s + " " + SpecialCode.get_code('wellness', 'diseased').to_s
		assert_equal 1, @pc2.illnesses.size
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
		assert @npc2.health.wellness == SpecialCode.get_code('wellness', 'diseased'), SpecialCode.get_text('wellness',@npc2.health.wellness)
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
	
	test "cure illness" do
		@pc = PlayerCharacter.find_by_name("sick pc")
		@disease = @pc.infections.first.disease
		assert_equal 4, @pc.illnesses.size
		assert_difference '@pc.stat.str', +5 do
			assert_difference '@pc.stat.int', +5 do
				assert_difference '@pc.stat.dex', +5 do
					assert Illness.cure(@pc, @disease)
				end
			end
		end
		assert @pc.illnesses.size == 3
		assert_difference '@pc.stat.str', +0 do
			assert_difference '@pc.stat.int', +0 do
				assert_difference '@pc.stat.dex', +0 do
					assert !Illness.cure(@pc, @disease)
				end
			end
		end
		assert_equal 3, @pc.illnesses.size
		@pc.infections.first.destroy
		@pc.infections.first.destroy
		assert_equal 1, @pc.illnesses.size
		@disease = @pc.infections.first.disease
		assert_difference '@pc.stat.str', +5 do
			assert_difference '@pc.stat.int', +5 do
				assert_difference '@pc.stat.dex', +5 do
					assert Illness.cure(@pc, @disease)
				end
			end
		end
		assert_equal 0, @pc.illnesses.size
		assert_equal SpecialCode.get_code('wellness','alive'), @pc.health.wellness
	end
end
