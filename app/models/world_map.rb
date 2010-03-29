class WorldMap < ActiveRecord::Base
	belongs_to :world
	belongs_to :feature
	
	has_many :done_events, :foreign_key => 'location_id', :class_name => 'DoneWorldEvent'
	
	def self.current_tile(bigy, bigx, y, x)
		find(:last, :conditions => ['bigypos = ? and bigxpos = ? and ypos = ? and xpos = ?', bigy, bigx, y, x])
	end
	
	def self.copy(world_map)
		@world_map_copy = WorldMap.new
		
		@world_map_copy.world_id = world_map.world_id
		@world_map_copy.xpos = world_map.xpos
		@world_map_copy.ypos = world_map.ypos
		@world_map_copy.bigxpos = world_map.bigxpos
		@world_map_copy.bigypos = world_map.bigypos
		@world_map_copy.feature_id = world_map.feature_id
	
		return @world_map_copy
	end
	
	#Pagination related stuff
	def self.per_page
		20
	end
	
	def self.get_page(page)
		paginate(:page => page )
	end
end
