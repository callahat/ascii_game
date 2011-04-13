class StatBaseItem < Stat
  belongs_to :base_item, :foreign_key => 'owner_id'
  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'BaseItem'
end
