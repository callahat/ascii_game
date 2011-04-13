class DoneLocalEvent < DoneEvent
  belongs_to :level_map, :foreign_key => "location_id"
  belongs_to :location, :foreign_key => "location_id", :class_name => "LevelMap"
end
