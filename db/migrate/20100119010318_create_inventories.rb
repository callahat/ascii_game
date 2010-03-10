class CreateInventories < ActiveRecord::Migration
  def self.up
    create_table :inventories do |t|
      t.integer "owner_id",                                   :null => false
      t.integer "item_id",                                    :null => false
	  t.integer "quantity",                   :default => 0,  :null => false
	  t.string  "kind",        :limit => 20,  :default => "", :null => false
      t.boolean "lock",                     :default => false
    end
	add_index "inventories", ["owner_id"], :name => "owner_id"
	add_index "inventories", ["item_id"], :name => "item_id"
	add_index "inventories", ["quantity"], :name => "quantity"
	add_index "inventories", ["kind","owner_id"], :name => "kind_owner_id"
	add_index "inventories", ["kind","owner_id","item_id"], :name => "kind_owner_id_item_id"
	
	Inventory.transaction do
	  KingdomItem.find_by_sql('select * from `kingdom_items`').each{ |i|
	    KingdomItem.create(:owner_id => i.kingdom_id, :item_id => i.item_id, :quantity => i.quantity) }
	  NpcStock.find_by_sql('select * from `npc_stocks`').each{ |i|
	    NpcStock.create(:owner_id => i.npc_id, :item_id => i.item_id, :quantity => i.quantity) }
	  PlayerCharacterItem.find_by_sql('select * from `player_character_items`').each{ |i|
	    PlayerCharacterItem.create(:owner_id => i.player_character_id, :item_id => i.item_id, :quantity => i.quantity) }
	end
	
	drop_table :kingdom_items
	drop_table :npc_stocks
	drop_table :player_character_items
  end

  def self.down
    raise raise ActiveRecord::IrreversibleMigration
    #For this migration to be reversible, the models must be rewritten
    #to not use single table inheritence
    #drop_table :inventories
  end
end
