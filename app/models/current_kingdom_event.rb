class CurrentKingdomEvent < CurrentEvent
	belongs_to :level_map, :foreign_key => 'location_id'
	belongs_to :feature, :through => :level_map
	
	#Change advance the current event
	def next_event
		
	end
end
