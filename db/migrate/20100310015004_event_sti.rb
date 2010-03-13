class EventSti < ActiveRecord::Migration
	def self.up
		self.make_new_columns
		self.update_event_rows
		self.table_cleanups
	end

	def self.down
	end
	
	#helpers
	def self.make_new_columns
		add_column :events, "kind",			:string, {:limit => 20}
		add_column :events, "thing_id",	:integer
		add_column :events, "flex",			:string, {:limit => 256}
		
		add_index :events, ["kind"], :name => "kind"
		add_index :events, ["kind","kingdom_id"], :name => "kind_kingdom_id"
		add_index :events, ["kind","player_id"], :name => "kind_player_id"
		add_index :events, ["armed","kind","kingdom_id"], :name => "armed_kind_kingdom_id"
		add_index :events, ["armed","kind","player_id"], :name => "armed_kind_player_id"
	end
	
	def self.update_event_rows
		#Creature
		Event.find_by_sql('select * from event_creatures').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventCreature")
			event.update_attribute(:thing_id, es.creature_id)
			event.update_attribute(:flex, es.low.to_s + ";" + es.high.to_s)
		}
		#Disease 2
		Event.find_by_sql('select * from event_diseases').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventDisease")
			event.update_attribute(:thing_id, es.disease_id)
			event.update_attribute(:flex, es.attributes["cures?"])
		}
		#Item 3
		Event.find_by_sql('select * from event_items').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventItem")
			event.update_attribute(:thing_id, es.item_id)
			event.update_attribute(:flex, es.number)
		}
		#Move 4
		Event.find_by_sql('select * from event_moves').each{|es|
			event = Event.find(es.event_id)
			case es.move_type.to_i
				when SpecialCode.get_code('move_type','local')
					event.update_attribute(:kind, "EventMoveLocal")
				when SpecialCode.get_code('move_type','local_relative')
					event.update_attribute(:kind, "EventMoveRelative")
				when SpecialCode.get_code('move_type','world')
					event.update_attribute(:kind, "EventMoveWorld")
			end
			event.update_attribute(:thing_id, es.move_id)
			event.update_attribute(:flex, es.move_type)
		}
		#Npc 5
		Event.find_by_sql('select * from event_npcs').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventNpc")
			event.update_attribute(:thing_id, es.npc_id)
			event.update_attribute(:flex, es.level_map_id)
		}
		#Pc 6
		Event.find_by_sql('select * from event_player_characters').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventPlayerCharacter")
			event.update_attribute(:thing_id, es.player_character)
		}
		#Quest 7
		Event.find_by_sql('select * from event_quests').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventQuest")
			event.update_attribute(:text, es.text)
		}
		#Stat 8
		Event.find_by_sql('select * from event_stats').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventStat")
			event.update_attribute(:text, es.text)
			event.update_attribute(:flex, es.gold.to_s + ";" + es.experience.to_s)
		}
		#Throne 9
		Event.find_by_sql('select * from events where event_type = 9').each{|event|
			event.update_attribute(:kind, "EventThrone")
		}
		#Castle 10
		Event.find_by_sql('select * from events where event_type = 10').each{|event|
			event.update_attribute(:kind, "EventCastle")
		}
		#Spawn Kingdom 11
		Event.find_by_sql('select * from events where event_type = 11').each{|event|
			event.update_attribute(:kind, "EventSpawnKingdom")
		}
		#Storm Gate 12
		Event.find_by_sql('select * from event_storm_gates').each{|es|
			event = Event.find(es.event_id)
			event.update_attribute(:kind, "EventStormGate")
			event.update_attribute(:thing_id, es.level_id)
		}
	end
	
	def self.table_cleanups
		remove_index :events, :name => "event_type"
		remove_index :events, :name => "armed_event_type_name"
		remove_column :events, :event_type
		
		drop_table :event_creatures
		drop_table :event_diseases
		drop_table :event_items
		drop_table :event_moves
		drop_table :event_npcs
		drop_table :event_player_characters
		drop_table :event_quests
		drop_table :event_stats
		drop_table :event_storm_gates
	end
end