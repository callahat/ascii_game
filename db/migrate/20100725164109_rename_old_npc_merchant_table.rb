class RenameOldNpcMerchantTable < ActiveRecord::Migration
	def self.up
		rename_table :npc_merchants, :npc_merchant_details
		remove_column :npcs, :npc_division
		add_column :npcs, :kind, :string, :limit => 20
		change_column :battle_enemies, :special, :string, :limit => 20
		change_column :images, :name, :string, :limit => 64
	end

	def self.down
		change_column :images, :name, :string, :limit => 32
		change_column :battle_enemies, :special, :integer
		remove_column :npcs, :kind
		add_column :npcs, :npc_division, :integer
		rename_table :npc_merchant_details, :npc_merchants
	end
end
