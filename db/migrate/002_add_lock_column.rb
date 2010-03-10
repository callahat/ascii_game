class AddLockColumn < ActiveRecord::Migration
  #:lock for pesimistic
  #:lock_version for optimistic

  def self.up
    #:lock for pesimistic
    #:lock_version for optimistic
    add_column :creatures,     :lock, :boolean, :default => false
    add_column :kingdom_items, :lock, :boolean, :default => false
    add_column :kingdoms,      :lock, :boolean, :default => false
    add_column :log_quest_creature_kills, :lock, :boolean, :default => false
    add_column :log_quest_kill_n_npcs,    :lock, :boolean, :default => false
    add_column :npc_merchants, :lock, :boolean, :default => false
    add_column :npc_stocks,    :lock, :boolean, :default => false
    add_column :npcs,          :lock, :boolean, :default => false
    add_column :player_character_items,   :lock, :boolean, :default => false
    add_column :player_characters,        :lock, :boolean, :default => false
	
	#Add table to keep track of locked tables, used when only one row needs created,
	#ie, lock player_character_items for an inventory item count
    create_table "table_locks", :force => true do |t|
      t.string  "name",         :limit => 32,  :default => "", :null => false
      t.boolean "lock",                        :default => false
    end
    add_index "table_locks", ["name"], :name => "name"
	
	TableLock.create(:name => "player_character_items")
	TableLock.create(:name => "npc_stocks")
	TableLock.create(:name => "npc_diseases")
	TableLock.create(:name => "infections")
	TableLock.create(:name => "pandemics")
  end

  def self.down
    remove_column :creatures,     :lock
    remove_column :kingdom_items, :lock
    remove_column :kingdoms,      :lock
    remove_column :log_quest_creature_kills, :lock
    remove_column :log_quest_kill_n_npcs,    :lock
    remove_column :npc_merchants, :lock
    remove_column :npc_stocks,    :lock
    remove_column :npcs,          :lock
    remove_column :player_character_items, :lock
    remove_column :player_characters,      :lock
	
	drop_table :table_locks
  end
end
