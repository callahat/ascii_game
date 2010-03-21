class CurrentWorldEvent < CurrentEvent
	belongs_to :world_map, :foreign_key => 'location_id'
	belongs_to :location, :foreign_key => 'location_id', :class_name => 'WorldMap'
	has_one :feature, :through => :world_map
	
	def make_done_event
		DoneWorldEvent.create(:event_id => event_id, :player_character_id => player_character_id, :location_id => location_id)
	end
end
