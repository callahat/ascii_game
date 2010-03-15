class DoneEvent < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :event
end
