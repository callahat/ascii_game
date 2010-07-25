require 'test_helper'

class NpcBlacksmithItemTest < ActiveSupport::TestCase
	def setup
		@npc = Npc.find_by_name("Healthy Npc")
		@npc2 = Npc.find_by_name("Sick NPC")
		@knife = BaseItem.find_by_name("knife")
		@mace = BaseItem.find_by_name("mace")
		@sword = BaseItem.find_by_name("swerd")
	end

	test "gen blacksmith item" do
		#Generate new item, where similar item does not exist
		assert_difference '@npc.npc_blacksmith_items.size', +1 do
			assert_difference 'Item.count', +1 do
				@new_bsi = NpcBlacksmithItem.gen_blacksmith_item(@npc, 0, @mace, 5, 5, false)
				assert @new_bsi.save!
				@npc.reload
			end
		end
		
		#generate new item, where similar item exists
		assert_difference '@npc.npc_blacksmith_items.size', +1 do
			assert_difference 'Item.count', +0 do
				@new_bsi = NpcBlacksmithItem.gen_blacksmith_item(@npc, 501, @knife, 5, 5, false)
				assert @new_bsi.save!
				@npc.reload
			end
		end
		
		#generate new, whether or not item exists
		assert_difference '@npc.npc_blacksmith_items.size', +1 do
			assert_difference 'Item.count', +1 do
				@new_bsi = NpcBlacksmithItem.gen_blacksmith_item(@npc, 0, @knife, 5, 5, true)
				assert @new_bsi.save!
				@npc.reload
			end
		end
	end

	test "gen blacksmith items" do
		#only one is made for each blacksmith skill level achieved
		foo = @npc.npc_blacksmith_items.size
		bar = Item.count
		assert msg_array = NpcBlacksmithItem.gen_blacksmith_items(@npc, 0, false)
		@npc.reload
		assert msg_array.collect{|a| a unless a =~ /Failed/}.compact.size == @npc.npc_blacksmith_items.size - foo
		assert foo < @npc.npc_blacksmith_items.size
		assert bar < Item.count
		
		@npc.npc_blacksmith_items.destroy_all
		
		foo = @npc.npc_blacksmith_items.size
		bar = Item.count
		assert msg_array = NpcBlacksmithItem.gen_blacksmith_items(@npc, 1000, false)
		@npc.reload
		assert msg_array.collect{|a| a unless a =~ /Failed/}.compact.size == @npc.npc_blacksmith_items.size - foo
		assert foo + 1 < @npc.npc_blacksmith_items.size, foo.to_s + " " + @npc.npc_blacksmith_items.size.to_s
		assert bar < Item.count

		@npc.npc_blacksmith_items.destroy_all
		
		foo = @npc.npc_blacksmith_items.size
		bar = Item.count
		assert msg_array = NpcBlacksmithItem.gen_blacksmith_items(@npc, 1000, true)
		@npc.reload
		assert msg_array.collect{|a| a unless a =~ /Failed/}.compact.size == @npc.npc_blacksmith_items.size - foo
		assert foo + 1 < @npc.npc_blacksmith_items.size, foo.to_s + " " + @npc.npc_blacksmith_items.size.to_s
		assert bar + 1 < Item.count
		
		#with npc that can already made a low level item
		foo = @npc2.npc_blacksmith_items.size
		bar = Item.count
		assert msg_array = NpcBlacksmithItem.gen_blacksmith_items(@npc2, 0, false)
		@npc2.reload
		assert msg_array.collect{|a| a unless a =~ /Failed/}.compact.size == @npc2.npc_blacksmith_items.size - foo
		assert foo == @npc2.npc_blacksmith_items.size
		assert bar == Item.count
		
		@npc.npc_blacksmith_items.destroy_all
		
		foo = @npc2.npc_blacksmith_items.size
		bar = Item.count
		assert msg_array = NpcBlacksmithItem.gen_blacksmith_items(@npc2, 1000, false)
		@npc2.reload
		assert msg_array.collect{|a| a unless a =~ /Failed/}.compact.size == @npc2.npc_blacksmith_items.size - foo
		assert foo < @npc2.npc_blacksmith_items.size, foo.to_s + " " + @npc2.npc_blacksmith_items.size.to_s
		assert bar < Item.count
	end
end
