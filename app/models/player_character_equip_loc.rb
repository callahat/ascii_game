class PlayerCharacterEquipLoc < ActiveRecord::Base
  belongs_to :player_character
  belongs_to :item
end
