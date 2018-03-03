class Infection < Illness
  belongs_to :player_character, :foreign_key => 'owner_id', :class_name => 'PlayerCharacter'
  belongs_to :owner,            :foreign_key => 'owner_id', :class_name => 'PlayerCharacter'
end
