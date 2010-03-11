class EventMove < Event
	belongs_to :level, :foreign_key => 'thing_id', :class_name => 'Level'
	belongs_to :world, :foreign_key => 'thing_id', :class_name => 'World'
	
	validates_presence_of :thing_id,:flex
	

end
