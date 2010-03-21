class CurrentKingdomEvent < CurrentEvent
	belongs_to :level_map, :foreign_key => 'location_id'
	belongs_to :location, :foreign_key => 'location_id', :class_name => 'LevelMap'
	has_one :feature, :through => :level_map
	
	def make_done_event
		DoneLocalEvent.create(:event_id => event_id, :player_character_id => player_character_id, :location_id => location_id)
	end
end
