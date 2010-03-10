class EventDisease < ActiveRecord::Base
	belongs_to :event
	belongs_to :disease

	validates_presence_of :event_id,:disease_id
end
