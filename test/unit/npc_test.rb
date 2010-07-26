require 'test_helper'

class NpcTest < ActiveSupport::TestCase
	def setup
		@npc = Npc.find_by_name("Healthy Npc")
		@npc2 = Npc.find_by_name("Sick NPC")
		@kingdom = Kingdom.find(1)
		@pc = PlayerCharacter.find_by_name("pc one")
		@sick_pc = PlayerCharacter.find_by_name("sick pc")
	end

	test "set npc stats" do
		@new_npc = Npc.create
		assert @new_npc.stat.nil?
		assert @new_npc.health.nil?
		Npc.set_npc_stats(@new_npc,50,10,10,10,10,10,10,10,5)
		@new_npc.reload
		assert @new_npc.stat
		assert @new_npc.health
		assert @new_npc.health.wellness == SpecialCode.get_code('wellness','alive')
	end
	
	test "award experience" do
		assert_difference '@npc.experience', +0 do
			@npc.award_exp(500)
			@npc.reload
		end
	end
	
	test "drop nth of gold" do
		nth_gold = @npc.gold / 2
		assert_difference '@npc.gold', -nth_gold do
			@npc.drop_nth_of_gold(2)
			@npc.reload
		end
	end
	
	test "generate stock merchant" do
		assert_difference 'NpcMerchant.count', +1 do
			assert_difference 'Image.count', +1 do
				assert_difference 'NpcMerchantDetail.count', +1 do
					assert_difference 'StatNpc.count', +1 do
						assert_difference 'HealthNpc.count', +1 do
							NpcMerchant.generate(@kingdom.id)
						end
					end
				end
			end
		end
	end
	
	test "generate stock guard" do
		assert_difference 'NpcGuard.count', +1 do
			assert_difference 'StatNpc.count', +1 do
				assert_difference 'HealthNpc.count', +1 do
					NpcGuard.generate(@kingdom.id)
				end
			end
		end
	end
	
	test "pay merchant" do
		assert_difference '@npc.gold', +500 do
			assert_difference '@npc.npc_merchant_detail.healing_sales', +500 do
				assert_difference '@npc.npc_merchant_detail.trainer_sales', +0 do
					assert_difference '@npc.npc_merchant_detail.blacksmith_sales', +0 do
						@npc.pay(500, :healing_sales)
					end
				end
			end
		end
		assert_difference '@npc.gold', +200 do
			assert_difference '@npc.npc_merchant_detail.healing_sales', +0 do
				assert_difference '@npc.npc_merchant_detail.trainer_sales', +200 do
					assert_difference '@npc.npc_merchant_detail.blacksmith_sales', +0 do
						@npc.pay(200, :trainer_sales)
					end
				end
			end
		end
		assert_difference '@npc.gold', +1500 do
			assert_difference '@npc.npc_merchant_detail.healing_sales', +0 do
				assert_difference '@npc.npc_merchant_detail.trainer_sales', +0 do
					assert_difference '@npc.npc_merchant_detail.blacksmith_sales', +1500 do
						@npc.pay(1500, :blacksmith_sales)
					end
				end
			end
		end
	end
	
	test "npc manufacture" do
		@pc.update_attribute(:gold, 150)
		@item1 = Item.find_by_name("Item1")
		@item2 = Item.find_by_name("Item2")
		assert_difference '@npc2.gold', +0 do
			assert_difference '@pc.gold', +0 do
				assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +0 do
					res, msg = @npc2.manufacture(@pc, -1)
					assert !res
					assert msg =~ /cannot make that/
				end
			end
		end
		
		assert_difference '@npc2.gold', +0 do
			assert_difference '@pc.gold', +0 do
				assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +0 do
					res, msg = @npc2.manufacture(@pc, @item2.id)
					assert !res
					assert msg =~ /cannot make #{@item2.name}/, msg
				end
			end
		end
		
		@pc.update_attribute(:gold, 0)
		assert_difference '@npc2.gold', +0 do
			assert_difference '@pc.gold', +0 do
				assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +0 do
					res, msg = @npc2.manufacture(@pc, @item1.id)
					assert !res
					assert msg =~ /Insufficient gold/
				end
			end
		end
		
		@pc.update_attribute(:gold, 500)
		
		npc_orig_gold = @npc2.gold
		pc_orig_gold = @pc.gold
		orig_kingdom_gold = @npc2.kingdom.gold
		assert_difference '@npc2.gold', +50 do
			assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +1 do
				res, msg = @npc2.manufacture(@pc, @item1.id)
				assert res
				assert msg =~ /Bought/
			end
		end
		assert pc_orig_gold - @pc.gold >= 50
		assert (orig_kingdom_gold + pc_orig_gold - @pc.gold - 50) == @npc2.kingdom.gold
		
		@pc.items.find(:first, :conditions => {:item_id => 1}).destroy
		
		npc_orig_gold = @npc2.gold
		pc_orig_gold = @pc.gold
		orig_kingdom_gold = @npc2.kingdom.gold
		assert_difference '@npc2.gold', +50 do
			res, msg = @npc2.manufacture(@pc, @item1.id)
			assert res
			assert msg =~ /Bought/
		end
		assert pc_orig_gold - @pc.gold >= 50
		assert (orig_kingdom_gold + pc_orig_gold - @pc.gold - 50) == @npc2.kingdom.gold
		assert @pc.items.exists?(:item_id => 1)
		assert @pc.items.find(:first, :conditions => {:item_id => 1}).quantity == 1
	end
	
	test "npc cure disease" do
		@disease = Disease.find_by_name("airbourne disease")
		res, msg = @npc.cure_disease(@sick_pc, @disease.id)
		assert !res
		assert msg =~ /cannot cure/
		
		@sick_pc.update_attribute(:gold, 0)
		res, msg = @npc2.cure_disease(@sick_pc, @disease.id)
		assert !res
		assert msg =~ /Not enough gold/, msg
		
		@sick_pc.update_attribute(:gold, 100000)
		npc_orig_gold = @npc2.gold
		pc_orig_gold = @sick_pc.gold
		orig_kingdom_gold = @npc2.kingdom.gold
		assert_difference '@npc2.gold', Disease.abs_cost(@disease) do
			assert_difference '@sick_pc.stat.mag', +5 do
				assert_difference '@sick_pc.stat.dfn', +5 do
					res, msg = @npc2.cure_disease(@sick_pc, @disease.id)
					assert res, msg
					assert msg =~ /Cured/
				end
			end
		end
		assert pc_orig_gold - @sick_pc.gold >= Disease.abs_cost(@disease)
		assert (orig_kingdom_gold + pc_orig_gold - @sick_pc.gold - Disease.abs_cost(@disease)) == @npc2.kingdom.gold
		
		assert_difference '@npc2.gold', +0 do
			assert_difference '@sick_pc.gold', +0 do
				assert_difference '@npc2.kingdom.gold', +0 do
					res, msg = @npc2.cure_disease(@sick_pc, @disease.id)
					assert !res
					assert msg =~ /do not have/
				end
			end
		end
		@sick_pc.infections.destroy_all
		Illness.infect(@sick_pc, @disease)
		assert @sick_pc.infections.size == 1
		assert @sick_pc.health.wellness == SpecialCode.get_code('wellness','diseased')
		res, msg = @npc2.cure_disease(@sick_pc, @disease.id)
		assert res
		assert @sick_pc.health.wellness == SpecialCode.get_code('wellness','alive')
	end
	
	test "npc heal HP and MP" do
		@sick_pc.update_attribute(:gold, 0)
		assert_difference '@sick_pc.health.HP', +0 do
			res, msg = @npc.heal(@sick_pc, "HP", 10)
			assert !res
			assert msg =~ /Not enough gold/
		end
		
		@sick_pc.update_attribute(:gold, 100000)
		npc_orig_gold = @npc.gold
		pc_orig_gold = @sick_pc.gold
		orig_kingdom_gold = @npc.kingdom.gold
		assert_difference '@npc.gold', MiscMath.point_recovery_cost(10) do
			assert_difference '@sick_pc.health.HP', +10 do
				res, msg = @npc.heal(@sick_pc, "HP", 10)
				assert res
				assert msg =~ /Restored HP/
			end
		end
		assert pc_orig_gold - @sick_pc.gold >= MiscMath.point_recovery_cost(10)
		assert (orig_kingdom_gold + pc_orig_gold - @sick_pc.gold - MiscMath.point_recovery_cost(10)) == @npc.kingdom.gold
		
		npc_orig_gold = @npc.gold
		pc_orig_gold = @sick_pc.gold
		orig_kingdom_gold = @npc.kingdom.gold
		assert_difference '@npc.gold', MiscMath.point_recovery_cost(10) do
			assert_difference '@sick_pc.health.MP', +10 do
				res, msg = @npc.heal(@sick_pc, "MP", 10)
				assert res
				assert msg =~ /Restored MP/
			end
		end
		assert pc_orig_gold - @sick_pc.gold >= MiscMath.point_recovery_cost(10)
		assert (orig_kingdom_gold + pc_orig_gold - @sick_pc.gold - MiscMath.point_recovery_cost(10)) == @npc.kingdom.gold
		
	end
end
