class DoneWorldEvent < DoneEvent
  belongs_to :world_map, :foreign_key => "location_id"
  belongs_to :location, :foreign_key => "location_id", :class_name => "WorldMap"
end
