class LevelMap < ActiveRecord::Base
	belongs_to :feature
	belongs_to :level
	
	has_many :event_npcs
	has_many :done_events
	has_many :kingdom_empty_shops
	
	def self.gen_level_map_squares(level, feature)
		#now, create the level map squares
		@x, @y, @savecount = 0, 0, 0
		while @y < level.maxy
			while @x < level.maxx
				@temp = LevelMap.new
				@temp.level_id = level.id
				@temp.feature_id = feature.id
				@temp.xpos = @x
				@temp.ypos = @y
				if @temp.save
					@savecount += 1
				end
				@x += 1
			end
			@x = 0
			@y += 1
		end
	end
end