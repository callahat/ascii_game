class RenameOldNpcMerchantTable < ActiveRecord::Migration
	def self.up
		rename_table :npc_merchants, :npc_merchant_details
	end

	def self.down
		rename_table :npc_merchant_details, :npc_merchants
	end
end
