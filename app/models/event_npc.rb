class EventNpc < ActiveRecord::Base
	belongs_to :event
	belongs_to :npc
	belongs_to :level_map

	validates_presence_of :event_id,:npc_id
end
