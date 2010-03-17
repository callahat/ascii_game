class CurrentKingdomEvent < CurrentEvent
	belongs_to :level_map, :foreign_key => 'location_id'
	belongs_to :location, :foreign_key => 'location_id', :class_name => 'LevelMap'
	has_one :feature, :through => :level_map
end
