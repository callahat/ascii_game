class CurrentWorldEvent < CurrentEvent
	belongs_to :world_map, :foreign_key => 'location_id'
	has_one :feature, :through => :world_map
	
	#Returns the events that are not completely done
	#MIGHT NOT NEED TO USE
	#def available_events(eid, lid, pcid=nil)
	#	
	#end
end
