class DropSpecialCodes < ActiveRecord::Migration
  def self.up
    drop_table :special_codes
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
