class PrefListEvent < PrefList
	belongs_to :event, :foreign_key => 'thing_id', :class_name => 'Event'
	belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Event'
end