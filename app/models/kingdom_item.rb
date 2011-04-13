class KingdomItem < Inventory
  belongs_to :kingdom, :foreign_key => 'owner_id', :class_name => 'Kingdom'
end
