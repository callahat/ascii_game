class DoneEventLocal < DoneEvent
	belongs_to :level_map, :foreign_key => "location_id"
end
