class NewTimestampsForDoneEvents < ActiveRecord::Migration
	def self.up
		add_column :done_events,									:created_at,	:timestamp
		add_column :creature_kills,								:updated_at,	:timestamp
		add_column :nonplayer_character_killers,	:created_at,	:timestamp
		add_column :player_character_killers,			:created_at,	:timestamp
		add_column :kingdom_notices,							:created_at,	:timestamp
		
		remove_column :done_events,									:datetime
		remove_column :nonplayer_character_killers,	:when
		remove_column :player_character_killers,		:when
		remove_column :kingdom_notices,							:datetime
	end

	def self.down
		add_column :done_events,									:datetime,	:timestamp
		add_column :nonplayer_character_killers,	:when,			:timestamp
		add_column :player_character_killers,			:when,			:timestamp
		add_column :kingdom_notices,							:datetime,	:timestamp
		
		remove_column :done_events,									:created_at
		remove_column :creature_kills,							:updated_at
		remove_column :nonplayer_character_killers,	:created_at
		remove_column :player_character_killers,		:created_at
		remove_column :kingdom_notices,							:created_at
	end
end
