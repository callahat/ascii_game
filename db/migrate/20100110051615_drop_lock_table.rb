class DropLockTable < ActiveRecord::Migration
  def self.up
    drop_table :lock_tables
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
