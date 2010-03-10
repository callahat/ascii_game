class HealthPc < Health
	belongs_to :player_character, :foreign_key => 'owner_id'
	belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'PlayerCharacter'
end