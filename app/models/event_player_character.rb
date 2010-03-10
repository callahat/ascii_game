class EventPlayerCharacter < ActiveRecord::Base
	belongs_to :event
	belongs_to :player_character

	validates_presence_of :event_id,:player_character_id
end
