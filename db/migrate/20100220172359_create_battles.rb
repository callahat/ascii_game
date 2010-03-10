class CreateBattles < ActiveRecord::Migration
  def self.up
    create_table :battles do |t|
      t.integer		"owner_id",     						:null => false
			t.integer		"gold",			:default => 0,	:null => false
      t.timestamps
    end
		add_index :battles, ["owner_id"], :name => "owner_id"
		
		create_table :battle_groups do |t|
      t.integer		"battle_id",     														:null => false
			t.string		"name",			:length => 64,	:default => "",	:null => false
    end
		add_index :battle_groups, ["battle_id"], :name => "battle_id"
		
		create_table :battle_enemies do |t|
			t.integer	"battle_id",														:null => false
			t.integer	"battle_group_id",											:null => false
			t.integer	"enemy_id",															:null => false
			t.integer "special", :limit => 1,		:default => 0
      t.string  "kind",    :limit => 20,  :default => "", :null => false
		end
		add_index :battle_enemies, ["battle_id"], :name => "battle_id"
		add_index :battle_enemies, ["battle_id", "battle_group_id"], :name => "battle_id_battle_group_id"
		add_index :battle_enemies, ["battle_id","kind"], :name => "battle_id_kind"
		add_index :battle_enemies, ["battle_id", "battle_group_id","kind"], :name => "battle_id_battle_group_id_kind"
		add_index :battle_enemies, ["battle_id", "battle_group_id","kind","special"], :name => "battle_id_battle_group_id_kind_special"
		add_index :battle_enemies, ["enemy_id"], :name => "enemy_id"
		
		create_table :battle_items do |t|
			t.integer	"battle_id",														:null => false
			t.integer	"item_id",															:null => false
			t.integer	"quantity",															:null => false
		end
		add_index :battle_items, ["battle_id"], :name => "battle_id"
		add_index :battle_items, ["item_id"], :name => "item_id"
		
  end

  def self.down
		drop_table :battle_groups
		drop_table :battle_enemies
		drop_table :battle_items
    drop_table :battles
  end
end
