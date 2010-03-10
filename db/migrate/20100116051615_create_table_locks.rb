class CreateTableLocks < ActiveRecord::Migration
  def self.up
    create_table :table_locks do |t|
      t.string :name,    :null => false
      t.boolean :locked, :default => false
      t.timestamps
    end

    add_index :table_locks, :name
    add_index :table_locks, :updated_at
  end

  def self.down
    drop_table :table_locks
  end
end
