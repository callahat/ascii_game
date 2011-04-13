class StatDisease < Stat
  belongs_to :disease, :foreign_key => 'owner_id'
  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'Disease'
end
