class DoneEvent < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :event
	belongs_to :level_map
end
