class NpcStock < Inventory
  belongs_to :npc_merchant, :foreign_key => 'owner_id', :class_name => 'NpcMerchant'
end
