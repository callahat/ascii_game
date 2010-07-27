class RenameOldNpcMerchantTable < ActiveRecord::Migration
	def self.up
		rename_table :npc_merchants, :npc_merchant_details
		add_column :npcs, :kind, :string, :limit => 20
		Npc.all.each{|npc|
			case npc.npc_division
				when SpecialCode.get_code('npc_division','guard')
					npc.update_attribute(:kind, "NpcGuard")
				when SpecialCode.get_code('npc_division','merchant')
					npc.update_attribute(:kind, "NpcMerchant")
			end
		}
		remove_column :npcs, :npc_division
		change_column :battle_enemies, :special, :string, :limit => 20
		change_column :images, :name, :string, :limit => 64
	end

	def self.down
		change_column :images, :name, :string, :limit => 32
		change_column :battle_enemies, :special, :integer
		add_column :npcs, :npc_division, :integer
		[[NpcMerchant, 'merchant'], [NpcGuard, 'guard']].each{|c|
			c[0].all.each{|npc|
				npc.update_attribute(:npc_division, SpecialCode.get_code('npc_division', c[1]))
			}
		}
		remove_column :npcs, :kind
		rename_table :npc_merchant_details, :npc_merchants
	end
end
