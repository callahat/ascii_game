class DropOldQuestAndLogTables < ActiveRecord::Migration
  def self.up
	drop_table :log_quest_creature_kills
	drop_table :log_quest_explores
	drop_table :log_quest_kill_n_npcs
	drop_table :log_quest_kill_pcs
	drop_table :log_quest_kill_s_npcs
    
    drop_table :quest_creature_kills
	drop_table :quest_explores
    drop_table :quest_items
	drop_table :quest_kill_n_npcs
	drop_table :quest_kill_pcs
	drop_table :quest_kill_s_npcs
  end

  def self.down
    raise raise ActiveRecord::IrreversibleMigration
  end
end
