class EventQuest < ActiveRecord::Base
	belongs_to :event
	belongs_to :quest

	validates_presence_of :event_id
end
