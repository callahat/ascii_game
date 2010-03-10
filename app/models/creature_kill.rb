class CreatureKill < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :creature
end
