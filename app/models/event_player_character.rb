class EventPlayerCharacter < EventLifeNeutral
	belongs_to :player_character, :foreign_key => 'thing_id'

	validates_presence_of :thing_id
	
	def make_happen(ig=nil)
		@pc = self.player_character
		if @pc.health.HP > 0 && @pc.health.wellness != SpecialCode.get_code('wellness','dead')
			return nil, true, ""
		else
			return {:action => 'complete'}, nil, @pc.name + " has shuffled from this mortal coil"
		end
	end
end
