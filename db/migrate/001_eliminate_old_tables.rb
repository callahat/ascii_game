class EliminateOldTables < ActiveRecord::Migration
  def self.up
    drop_table :lock_tables
    drop_table :special_codes
  end

  def self.down
    raise IrreversibleMigration
  end
end
