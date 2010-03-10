class EventStormGate < ActiveRecord::Base
	belongs_to :event
	belongs_to :level
	
	validates_presence_of :level_id,:event_id
end
