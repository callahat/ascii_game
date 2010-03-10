class EventItem < ActiveRecord::Base
	belongs_to :event
	belongs_to :item

	validates_presence_of :event_id,:item_id,:number
	validates_inclusion_of :number, :in => 1..100, :message => ' must be between 1 and 100.'
end
