require 'test_helper'

class InventoryTest < ActiveSupport::TestCase
	test "verify inventory fixtures loaded" do
		assert Inventory.count == 41
		assert PlayerCharacterItem.count == 6
		assert NpcStock.count == 4
		assert KingdomItem.count == 31
	end

	test "remove item" do
		[PlayerCharacterItem, NpcStock, KingdomItem].each{|inv_type|
			pci = inv_type.find(:first, :conditions => ['quantity = 1'])
			assert pci.quantity == 1, "Initial quanitity (" + pci.quantity.to_s + ") not 1 for first " + inv_type.to_s
			assert inv_type.update_inventory(pci.owner_id, pci.item_id, -1), "Failed to take one item from first " + inv_type.to_s
			pci.reload
			assert pci.quantity == 0, "New quanitity not 0 for first " + inv_type.to_s
		}
	end

	test "add item" do
		[PlayerCharacterItem, NpcStock, KingdomItem].each{|inv_type|
			pci = inv_type.find(:first, :conditions => ['quantity = 1'])
			assert pci.quantity == 1, "Initial quanitity (" + pci.quantity.to_s + ") not 1 for first " + inv_type.to_s
			assert inv_type.update_inventory(pci.owner_id, pci.item_id, 1), "Failed to take one item from first " + inv_type.to_s
			pci.reload
			assert pci.quantity == 2, "New quanitity not 2 for first " + inv_type.to_s
		}
	end

	test "add new item" do
		[PlayerCharacterItem, NpcStock, KingdomItem].each{|inv_type|
			pci = inv_type.find(:first, :conditions => ['owner_id = 1 and item_id = 99'])
			assert pci.nil?, "Item already exists for " + inv_type.to_s
			assert inv_type.update_inventory(1, 99, 14), "Failed to create item from " + inv_type.to_s
			pci = inv_type.find(:first, :conditions => ['owner_id = 1 and item_id = 99'])
			assert pci.quantity == 14, "New quanitity not 14 for " + inv_type.to_s
			assert pci.item_id == 99, "New item id not correct for " + inv_type.to_s
			assert pci.owner_id == 1, "New owner id not correct for " + inv_type.to_s
		}
	end

	test "remove too many" do
		[PlayerCharacterItem, NpcStock, KingdomItem].each{|inv_type|
			pci = inv_type.find(:first, :conditions => ['quantity = 1'])
			assert pci.quantity == 1, "Initial quanitity (" + pci.quantity.to_s + ") not 1 for first " + inv_type.to_s
			assert !inv_type.update_inventory(pci.owner_id, pci.item_id, -10), "Removed too many from " + inv_type.to_s
			pci.reload
			assert pci.quantity == 1, "New quanitity not 1 for first " + inv_type.to_s
		}
	end

	test "pagination" do
		assert Inventory.get_page(1).to_a.size == 25, Inventory.get_page(1).size.to_s
		assert PlayerCharacterItem.get_page(1).to_a.size == 6
		assert NpcStock.get_page(1).to_a.size == 4
		assert KingdomItem.get_page(1).to_a.size == 25
		assert_equal KingdomItem.get_page(2).to_a.size, 6
		assert KingdomItem.get_page(1,1).to_a.size == 25
		assert KingdomItem.get_page(2,1).to_a.size == 5
		assert KingdomItem.get_page(1,2).to_a.size == 1
	end
end
