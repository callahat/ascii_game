class StatEventStat < Stat
	belongs_to :event_stat, :foreign_key => 'owner_id'
	belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'EventStat'
end
