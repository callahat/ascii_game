class EventStat < ActiveRecord::Base
	belongs_to :event

	has_one :stat, :foreign_key => 'owner_id', :class_name => 'StatEventStat'
	has_one :health, :foreign_key => 'owner_id', :class_name => 'HealthEventStat'

	
	validates_presence_of :event_id,:gold,:experience
end