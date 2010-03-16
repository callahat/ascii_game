class DoneWorldEvent < DoneEvent
	belongs_to :world_map, :foreign_key => "location_id"
end
