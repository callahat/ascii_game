class EventMove < ActiveRecord::Base
	belongs_to :event

	belongs_to :level, :foreign_key => 'move_id', :class_name => 'Level'
	belongs_to :world, :foreign_key => 'move_id', :class_name => 'World'
	
	validates_presence_of :move_type,:event_id
end
