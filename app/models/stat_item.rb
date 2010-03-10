class StatItem < Stat
	belongs_to :item, :foreign_key => 'owner_id'
	belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'Item'
end
