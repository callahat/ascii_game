class CreateCurrentEvents < ActiveRecord::Migration
	def self.up
		create_table :current_events do |t|
			t.integer		"player_character_id",					:null => false
			t.integer		"event_id",											:null => false
			t.integer		"location_id",									:null => false
			t.string		"kind",													:null => false

			t.timestamps
		end
		add_index :current_events, ["player_character_id"], :name => "player_character_id"
		add_index :current_events, ["player_character_id", "kind"], :name => "player_character_id_kind"
		add_index :current_events, ["event_id"], :name => "event_id"
		add_index :current_events, ["location_id"], :name => "location_id"
		add_index :current_events, ["kind"], :name => "kind"
		add_index :current_events, ["kind", "event_id","location_id"], :name => "kind_event_id_location_id"
		add_index :current_events, ["kind", "player_character_id", "event_id","location_id"],
																:name => "kind_player_character_id_event_id_location_id"
		
		add_column :done_events,		:location_id,	:integer,									:null => false
		add_column :done_events,		:kind,				:string,	:length => 20,	:null => false
		
		add_index :done_events, ["location_id"], :name => "location_id"
		add_index :done_events, ["kind"], :name => "kind"
		add_index :done_events, ["kind", "player_character_id", "location_id"],
															:name => "kind_player_character_id_location_id"
		add_index :done_events, ["kind", "player_character_id", "location_id", "event_id"],
															:name => "kind_player_character_id_location_id_event_id"
		
		#update the done events
		DoneEvent.all.each{|de|
			if de.level_map_id
				de.update_attribute(:kind, "DoneEventKingdom")
				de.update_attribute(:location_id, de.level_map_id)
			elsif de.world_map_id
				de.update_attribute(:kind, "DoneEventWorld")
				de.update_attribute(:location_id, de.world_map_id)
			else
				p "Unknown done event, id:" + de.id.to_s
			end }
		
		#Clean up
		remove_column :done_events, :level_map_id
		remove_column :done_events, :world_map_id
		
		#Update the done events table for inheritence
		remove_index :done_events, :level_map_id rescue p "level_map_id index removal failed"
		remove_index :done_events, :world_map_id rescue p "world_map_id index removal failed"
		remove_index :done_events, :player_character_id_world_map_id rescue  p "pcid wmid index removal failed"
		remove_index :done_events, :event_id_player_id_level_map_id rescue  p "eid pid lmid index removal failed"
	end

	def self.down
		drop_table :current_events
	end
end
