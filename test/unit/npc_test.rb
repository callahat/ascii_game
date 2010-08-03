require 'test_helper'

class NpcTest < ActiveSupport::TestCase
	def setup
		@npc = Npc.find_by_name("Healthy Npc")
		@npc2 = Npc.find_by_name("Sick NPC")
		@kingdom = Kingdom.find(1)
		@pc = PlayerCharacter.find_by_name("Test PC One")
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
		assert_difference '@npc.gold', +0 do
			assert_difference '@pc.gold', +0 do
				assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +0 do
					res, msg = @npc.manufacture(@pc, -1)
					assert !res
					assert msg =~ /cannot make that/
				end
			end
		end
		
		assert_difference '@npc.gold', +0 do
			assert_difference '@pc.gold', +0 do
				assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +0 do
					res, msg = @npc.manufacture(@pc, @item2.id)
					assert !res
					assert msg =~ /cannot make #{@item2.name}/, msg
				end
			end
		end
		
		@pc.update_attribute(:gold, 0)
		assert_difference '@npc.gold', +0 do
			assert_difference '@pc.gold', +0 do
				assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +0 do
					res, msg = @npc.manufacture(@pc, @item1.id)
					assert !res
					assert msg =~ /Insufficient gold/
				end
			end
		end
		
		@pc.update_attribute(:gold, 500)
		
		npc_orig_gold = @npc.gold
		pc_orig_gold = @pc.gold
		orig_kingdom_gold = @npc.kingdom.gold
		assert_difference '@npc.gold', +50 do
			assert_difference '@pc.items.find(:first, :conditions => {:item_id => 1}).quantity', +1 do
				res, msg = @npc.manufacture(@pc, @item1.id)
				assert res
				assert msg =~ /Bought/
			end
		end
		assert pc_orig_gold - @pc.gold >= 50
		assert (orig_kingdom_gold + pc_orig_gold - @pc.gold - 50) == @npc.kingdom.gold
		
		@pc.items.find(:first, :conditions => {:item_id => 1}).destroy
		
		npc_orig_gold = @npc.gold
		pc_orig_gold = @pc.gold
		orig_kingdom_gold = @npc.kingdom.gold
		assert_difference '@npc.gold', +50 do
			res, msg = @npc.manufacture(@pc, @item1.id)
			assert res
			assert msg =~ /Bought/
		end
		assert pc_orig_gold - @pc.gold >= 50
		assert (orig_kingdom_gold + pc_orig_gold - @pc.gold - 50) == @npc.kingdom.gold
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
	
	test "npc max head HP and MP" do
		assert @npc.max_heal(@sick_pc, "HP") == 10, @npc.max_heal(@sick_pc, "HP")
		assert @npc.max_heal(@sick_pc, "MP") == 0
		
		@sick_pc.health.update_attribute(:HP, 28)
		@sick_pc.health.update_attribute(:MP, 23)
		
		assert @npc.max_heal(@sick_pc, "HP") == 2
		assert @npc.max_heal(@sick_pc, "MP") == 7
		
		@sick_pc.health.update_attribute(:HP, 30)
		@sick_pc.health.update_attribute(:MP, 35)
		
		assert @npc.max_heal(@sick_pc, "HP") == 0
		assert @npc.max_heal(@sick_pc, "MP") == 0, @npc.max_heal(@sick_pc, "MP")
	end
	
	test "npc heal HP and MP" do
		@sick_pc.update_attribute(:gold, 0)
		@sick_pc.health.update_attribute(:MP, 0)
		assert_difference '@sick_pc.health.HP', +0 do
			res, msg = @npc.heal(@sick_pc, "HP")
			assert !res
			assert msg =~ /Not enough gold/
		end
		
		@sick_pc.update_attribute(:gold, 100000)
		npc_orig_gold = @npc.gold
		pc_orig_gold = @sick_pc.gold
		orig_kingdom_gold = @npc.kingdom.gold
		assert_difference '@npc.gold', MiscMath.point_recovery_cost(10) do
			assert_difference '@sick_pc.health.HP', +10 do
				res, msg = @npc.heal(@sick_pc, "HP")
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
				res, msg = @npc.heal(@sick_pc, "MP")
				assert res
				assert msg =~ /Restored MP/
			end
		end
		assert pc_orig_gold - @sick_pc.gold >= MiscMath.point_recovery_cost(10)
		assert (orig_kingdom_gold + pc_orig_gold - @sick_pc.gold - MiscMath.point_recovery_cost(10)) == @npc.kingdom.gold
	end
	
	test "npc train" do
		max_train = @npc.npc_merchant_detail.max_skill_taught
		
		Stat.symbols.each{|at|
			@stat = Stat.new
			base_at = @pc.base_stat[at]
			
			#negative stat
			@stat[at] = -1
			res, msg = @npc.train(@pc, @stat)
			assert !res
			assert @stat.errors.size == 1
			assert @stat.errors.full_messages.first =~ /negative/
			@stat.errors.clear
			
			#greater than npc is able
			@stat[at] = (base_at * max_train / 100.0).to_i + 1
			res, msg = @npc.train(@pc, @stat)
			assert !res
			assert @stat.errors.size == 1
			assert @stat.errors.full_messages.first =~ /cannot gain/
			@stat.errors.clear
			
			#within limit, not enough cash
			@pc.update_attribute(:gold, 0)
			@stat[at] = (base_at * max_train / 100.0).to_i - 1
			res, msg = @npc.train(@pc, @stat)
			assert !res, msg
			assert @stat.errors.size == 0, @stat.errors.full_messages
			assert msg =~ /Not enough gold/
			
			#at limit, not enough cash
			@stat[at] = (base_at * max_train / 100.0).to_i - 1
			res, msg = @npc.train(@pc, @stat)
			assert !res, msg
			assert @stat.errors.size == 0, @stat.errors.full_messages
			assert msg =~ /Not enough gold/
			
			#with limit, enough cash
			@pc.update_attribute(:gold, 10000)
			@stat[at] = (base_at * max_train / 100.0).to_i
			@pretax = @stat.sum_points * @pc.level * 10
			@tax = (@pretax * @npc.kingdom.tax_rate / 100.0).to_i
			@total = @pretax + @tax
			
			assert_difference '@pc.base_stat[at]', +0 do
				assert_difference '@pc.trn_stat[at]', +(base_at * max_train / 100.0).to_i do
					assert_difference '@pc.stat[at]', +(base_at * max_train / 100.0).to_i do
						assert_difference '@npc.gold', @pretax do
							assert_difference '@npc.kingdom.gold', @tax do
								assert_difference '@pc.gold', -@total do
									res, msg = @npc.train(@pc, @stat)
									assert res, msg
									assert msg =~ /successful/
								end
							end
						end
					end
				end
			end
		}
		
		#multi attribute update
		#over
		@sick_pc.update_attribute(:gold, 10000)
		@stat = Stat.new
		base_str = @sick_pc.base_stat[:str]
		base_dex = @sick_pc.base_stat[:dex]
		@stat[:str] = (base_str * max_train / 100.0).to_i + 1
		@stat[:dex] = (base_dex * max_train / 100.0).to_i + 1
		res, msg = @npc.train(@sick_pc, @stat)
		assert !res, msg
		assert @stat.errors.size == 2, msg
		assert @stat.errors.full_messages.first =~ /cannot gain/
		@stat.errors.clear
		
		#just right
		@stat[:str] = (base_str * max_train / 200.0).to_i
		@stat[:dex] = (base_dex * max_train / 200.0).to_i
		
		assert_difference '@sick_pc.base_stat[:str]', +0 do
			assert_difference '@sick_pc.base_stat[:dex]', +0 do
				assert_difference '@sick_pc.trn_stat[:str]', +(base_str * max_train / 200.0).to_i do
					assert_difference '@sick_pc.stat[:str]', +(base_str * max_train / 200.0).to_i do
						assert_difference '@sick_pc.trn_stat[:dex]', +(base_dex * max_train / 200.0).to_i do
							assert_difference '@sick_pc.stat[:dex]', +(base_dex * max_train / 200.0).to_i do
								res, msg = @npc.train(@sick_pc, @stat)
								assert res, msg + @stat.errors.full_messages.inspect
								assert msg =~ /successful/
							end
						end
					end
				end
			end
		end
	end
	
	test "npc sell used to pc" do
		@item4 = Item.find(4)
		@item5 = Item.find(5)
		res, msg = @npc.sell_used_to(@pc, @item5.id)
		assert !res
		assert msg =~ /does not have one/
		
		@pc.update_attribute(:gold, 0)
		
		assert @pc.items.find(:first, :conditions => ["item_id = ?", @item4.id]).nil?
		assert_difference '@npc.gold', +0 do
			assert_difference '@npc.npc_stocks.find(:first, :conditions => ["item_id = ?", @item4.id]).quantity', -0 do
				res, msg = @npc.sell_used_to(@pc, @item4.id)
				assert !res
				assert msg =~ /price range/
			end
		end
		assert @pc.items.find(:first, :conditions => ["item_id = ?", @item4.id]).nil?
		
		@pc.update_attribute(:gold, 1000)
		npc_orig_gold = @npc.gold
		pc_orig_gold = @pc.gold
		orig_kingdom_gold = @npc.kingdom.gold
		assert_difference '@npc.gold', +@item4.used_price do
			assert_difference '@npc.npc_stocks.find(:first, :conditions => ["item_id = ?", @item4.id]).quantity', -1 do
				res, msg = @npc.sell_used_to(@pc, @item4.id)
				assert res
				assert msg =~ /Bought a/
			end
		end
		assert @pc.items.find(:first, :conditions => ["item_id = ?", @item4.id]).quantity == 1
		@npc.reload
		assert pc_orig_gold - @pc.gold == (@npc.gold - npc_orig_gold) + (@npc.kingdom.gold - orig_kingdom_gold)
		
		res, msg = @npc.sell_used_to(@pc, @item4.id)
		assert !res
		assert msg =~ /does not have a/
	end
	
	test "npc buy from pc" do
		@item1 = Item.find(1)
		@item5 = Item.find(5)
		
		res, msg = @npc.buy_from(@pc, @item5.id)
		assert !res
		assert msg =~ /not have one/
		
		assert_difference '@pc.gold', +@item1.resell_value do
			assert_difference '@npc.npc_stocks.find(:first, :conditions => ["item_id = ?", @item1.id]).quantity', +1 do
				res, msg = @npc.buy_from(@pc, @item1.id)
				assert res
				assert msg =~ /Sold/
			end
		end
		
		res, msg = @npc.buy_from(@pc, @item1.id)
		assert !res
		assert msg =~ /not have a/
	end
end
