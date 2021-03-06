class IncreaseSomeIntColumnSizes < ActiveRecord::Migration
  def up
    change_column :kingdoms, :gold, :integer, limit: 8
    change_column :npc_merchant_details, :healing_sales, :integer, limit: 8
    change_column :npc_merchant_details, :blacksmith_sales, :integer, limit: 8
    change_column :npc_merchant_details, :trainer_sales, :integer, limit: 8
    change_column :player_characters, :gold, :integer, limit: 8
  end

  def down
    change_column :kingdoms, :gold, :integer, limit: 4
    change_column :npc_merchant_details, :healing_sales, :integer, limit: 4
    change_column :npc_merchant_details, :blacksmith_sales, :integer, limit: 4
    change_column :npc_merchant_details, :trainer_sales, :integer, limit: 4
    change_column :player_characters, :gold, :integer, limit: 4
  end
end
