# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100703004220) do

  create_table "attack_spells", :force => true do |t|
    t.string  "name",         :limit => 32,  :default => "", :null => false
    t.string  "description",  :limit => 256
    t.integer "min_level",                                   :null => false
    t.integer "min_dam",                                     :null => false
    t.integer "max_dam",                                     :null => false
    t.integer "dam_from_mag",                                :null => false
    t.integer "dam_from_int",                                :null => false
    t.integer "mp_cost",                                     :null => false
    t.integer "hp_cost",                                     :null => false
    t.boolean "splash",                                      :null => false
  end

  add_index "attack_spells", ["min_level"], :name => "min_level"
  add_index "attack_spells", ["name"], :name => "name"

  create_table "base_items", :force => true do |t|
    t.string  "name",           :limit => 32,  :default => "", :null => false
    t.string  "description",    :limit => 256
    t.integer "equip_loc",                                     :null => false
    t.integer "price",                                         :null => false
    t.integer "race_body_type"
  end

  add_index "base_items", ["name"], :name => "name"
  add_index "base_items", ["price", "race_body_type"], :name => "price_race_body_type"
  add_index "base_items", ["price"], :name => "price"
  add_index "base_items", ["race_body_type"], :name => "race_body_type"

  create_table "battle_enemies", :force => true do |t|
    t.integer "battle_id",                                     :null => false
    t.integer "battle_group_id",                               :null => false
    t.integer "enemy_id",                                      :null => false
    t.integer "special",         :limit => 1,  :default => 0
    t.string  "kind",            :limit => 20, :default => "", :null => false
  end

  add_index "battle_enemies", ["battle_id", "battle_group_id", "kind", "special"], :name => "battle_id_battle_group_id_kind_special"
  add_index "battle_enemies", ["battle_id", "battle_group_id", "kind"], :name => "battle_id_battle_group_id_kind"
  add_index "battle_enemies", ["battle_id", "battle_group_id"], :name => "battle_id_battle_group_id"
  add_index "battle_enemies", ["battle_id", "kind"], :name => "battle_id_kind"
  add_index "battle_enemies", ["battle_id"], :name => "battle_id"
  add_index "battle_enemies", ["enemy_id"], :name => "enemy_id"

  create_table "battle_groups", :force => true do |t|
    t.integer "battle_id",                 :null => false
    t.string  "name",      :default => "", :null => false
  end

  add_index "battle_groups", ["battle_id"], :name => "battle_id"

  create_table "battle_items", :force => true do |t|
    t.integer "battle_id", :null => false
    t.integer "item_id",   :null => false
    t.integer "quantity",  :null => false
  end

  add_index "battle_items", ["battle_id"], :name => "battle_id"
  add_index "battle_items", ["item_id"], :name => "item_id"

  create_table "battles", :force => true do |t|
    t.integer  "owner_id",                  :null => false
    t.integer  "gold",       :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "battles", ["owner_id"], :name => "owner_id"

  create_table "blacksmith_skills", :force => true do |t|
    t.integer "base_item_id", :null => false
    t.integer "min_sales",    :null => false
    t.integer "min_mod",      :null => false
    t.integer "max_mod",      :null => false
  end

  add_index "blacksmith_skills", ["base_item_id"], :name => "base_item_id"
  add_index "blacksmith_skills", ["min_sales"], :name => "min_sales"

  create_table "c_classes", :force => true do |t|
    t.string  "name",           :limit => 32,  :default => "", :null => false
    t.string  "description",    :limit => 256
    t.boolean "attack_spells"
    t.boolean "healing_spells"
    t.integer "freepts",                                       :null => false
  end

  add_index "c_classes", ["name"], :name => "name"

  create_table "creature_kills", :force => true do |t|
    t.integer  "player_character_id",                :null => false
    t.integer  "creature_id",                        :null => false
    t.integer  "number",              :default => 0, :null => false
    t.datetime "updated_at"
  end

  add_index "creature_kills", ["creature_id"], :name => "creature_id"
  add_index "creature_kills", ["player_character_id", "creature_id"], :name => "player_character_creature_id"
  add_index "creature_kills", ["player_character_id"], :name => "player_character_id"

  create_table "creatures", :force => true do |t|
    t.string  "name",         :limit => 32,  :default => "",    :null => false
    t.string  "description",  :limit => 256
    t.integer "experience",                                     :null => false
    t.integer "HP",                                             :null => false
    t.integer "gold",                                           :null => false
    t.integer "image_id",                                       :null => false
    t.integer "player_id",                                      :null => false
    t.boolean "public",                      :default => false, :null => false
    t.integer "kingdom_id",                                     :null => false
    t.integer "number_alive",                                   :null => false
    t.float   "fecundity",                                      :null => false
    t.integer "disease_id"
    t.boolean "armed",                       :default => false
    t.integer "being_fought",                :default => 0
    t.boolean "lock",                        :default => false
  end

  add_index "creatures", ["disease_id"], :name => "disease_id"
  add_index "creatures", ["experience"], :name => "experience"
  add_index "creatures", ["image_id"], :name => "FK_creatures_images"
  add_index "creatures", ["kingdom_id"], :name => "kingdom_id"
  add_index "creatures", ["name"], :name => "name"
  add_index "creatures", ["player_id"], :name => "player_id"
  add_index "creatures", ["public"], :name => "public"

  create_table "current_events", :force => true do |t|
    t.integer  "player_character_id",                 :null => false
    t.integer  "event_id"
    t.integer  "location_id",                         :null => false
    t.integer  "priority",            :default => 0,  :null => false
    t.integer  "completed",           :default => -1
    t.string   "kind",                :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "current_events", ["event_id"], :name => "event_id"
  add_index "current_events", ["kind", "event_id", "location_id"], :name => "kind_event_id_location_id"
  add_index "current_events", ["kind", "player_character_id", "event_id", "location_id"], :name => "kind_player_character_id_event_id_location_id"
  add_index "current_events", ["kind"], :name => "kind"
  add_index "current_events", ["location_id"], :name => "location_id"
  add_index "current_events", ["player_character_id", "kind"], :name => "player_character_id_kind"
  add_index "current_events", ["player_character_id"], :name => "player_character_id"

  create_table "diseases", :force => true do |t|
    t.string  "name",             :limit => 32,  :default => "", :null => false
    t.string  "description",      :limit => 256
    t.float   "virility",                                        :null => false
    t.integer "trans_method",                                    :null => false
    t.integer "HP_per_turn"
    t.integer "MP_per_turn"
    t.boolean "NPC_fatal"
    t.float   "peasant_fatality"
    t.integer "min_peasants",                                    :null => false
  end

  add_index "diseases", ["name"], :name => "name"

  create_table "done_events", :force => true do |t|
    t.integer  "event_id",                            :null => false
    t.integer  "player_character_id",                 :null => false
    t.integer  "location_id",                         :null => false
    t.string   "kind",                :default => "", :null => false
    t.datetime "created_at"
  end

  add_index "done_events", ["event_id", "player_character_id"], :name => "event_id_player_character_id"
  add_index "done_events", ["event_id", "player_character_id"], :name => "event_id_player_id_level_map_id"
  add_index "done_events", ["event_id"], :name => "event_id"
  add_index "done_events", ["kind", "player_character_id", "location_id", "event_id"], :name => "kind_player_character_id_location_id_event_id"
  add_index "done_events", ["kind", "player_character_id", "location_id"], :name => "kind_player_character_id_location_id"
  add_index "done_events", ["kind"], :name => "kind"
  add_index "done_events", ["location_id"], :name => "location_id"
  add_index "done_events", ["player_character_id"], :name => "player_character_id"
  add_index "done_events", ["player_character_id"], :name => "player_character_id_world_map_id"

  create_table "done_quests", :force => true do |t|
    t.integer  "quest_id",            :null => false
    t.integer  "player_character_id", :null => false
    t.datetime "created_at",          :null => false
  end

  add_index "done_quests", ["player_character_id"], :name => "player_character_id"
  add_index "done_quests", ["quest_id", "player_character_id"], :name => "quest_id_player_character_id"
  add_index "done_quests", ["quest_id"], :name => "quest_id"

  create_table "events", :force => true do |t|
    t.integer "kingdom_id",                                       :null => false
    t.integer "player_id",                                        :null => false
    t.integer "event_rep_type",                                   :null => false
    t.integer "event_reps"
    t.string  "name",           :limit => 32,  :default => "",    :null => false
    t.boolean "armed",                         :default => false
    t.integer "cost",                                             :null => false
    t.text    "text"
    t.string  "kind",           :limit => 20
    t.integer "thing_id"
    t.string  "flex",           :limit => 256
  end

  add_index "events", ["armed", "kind", "kingdom_id"], :name => "armed_kind_kingdom_id"
  add_index "events", ["armed", "kind", "player_id"], :name => "armed_kind_player_id"
  add_index "events", ["armed", "kingdom_id"], :name => "armed_kingdom_id"
  add_index "events", ["armed", "player_id"], :name => "armed_player_id"
  add_index "events", ["kind", "kingdom_id"], :name => "kind_kingdom_id"
  add_index "events", ["kind", "player_id"], :name => "kind_player_id"
  add_index "events", ["kind"], :name => "kind"
  add_index "events", ["kingdom_id"], :name => "kingdom_id"
  add_index "events", ["player_id"], :name => "player_id"

  create_table "feature_events", :force => true do |t|
    t.integer "feature_id",                    :null => false
    t.integer "event_id",                      :null => false
    t.float   "chance",     :default => 100.0, :null => false
    t.integer "priority"
    t.boolean "choice",     :default => false
  end

  add_index "feature_events", ["event_id"], :name => "event_id"
  add_index "feature_events", ["feature_id", "priority", "choice"], :name => "feature_id_priority_choice"
  add_index "feature_events", ["feature_id", "priority"], :name => "feature_priority_id"
  add_index "feature_events", ["feature_id"], :name => "feature_id"

  create_table "features", :force => true do |t|
    t.string  "name",             :limit => 64
    t.string  "description",      :limit => 256
    t.integer "action_cost"
    t.integer "image_id",                                           :null => false
    t.integer "player_id",                                          :null => false
    t.boolean "world_feature"
    t.integer "kingdom_id",                                         :null => false
    t.boolean "public"
    t.integer "cost"
    t.integer "num_occupants",                   :default => 0,     :null => false
    t.boolean "armed",                           :default => false
    t.integer "store_front_size",                :default => 0
  end

  add_index "features", ["armed", "world_feature", "name"], :name => "armed_wrold_feature_name"
  add_index "features", ["image_id"], :name => "image_id"
  add_index "features", ["kingdom_id"], :name => "kingdom_id"
  add_index "features", ["name"], :name => "name"
  add_index "features", ["player_id"], :name => "player_id"
  add_index "features", ["world_feature", "kingdom_id", "public"], :name => "kingdom_id_public_world"
  add_index "features", ["world_feature", "kingdom_id"], :name => "world_feature_kingdom_id"
  add_index "features", ["world_feature", "public"], :name => "world_feature_public"

  create_table "forum_nodes", :force => true do |t|
    t.integer  "player_id",                                      :null => false
    t.integer  "forum_node_id"
    t.string   "name",          :limit => 64
    t.text     "text"
    t.datetime "datetime"
    t.boolean  "is_locked",                   :default => false
    t.boolean  "is_hidden",                   :default => false
    t.boolean  "is_deleted",                  :default => false
    t.boolean  "is_mods_only",                :default => false
    t.integer  "elders",                      :default => 0,     :null => false
    t.text     "edit_notices"
  end

  add_index "forum_nodes", ["datetime"], :name => "datetime"
  add_index "forum_nodes", ["forum_node_id", "is_deleted"], :name => "forum_node_id_is_deleted"
  add_index "forum_nodes", ["forum_node_id", "is_hidden"], :name => "forum_node_id_is_hidden"
  add_index "forum_nodes", ["forum_node_id", "is_locked"], :name => "forum_node_id_is_locked"
  add_index "forum_nodes", ["forum_node_id", "is_mods_only"], :name => "forum_node_id_is_mods_only"
  add_index "forum_nodes", ["forum_node_id"], :name => "forum_node_id"
  add_index "forum_nodes", ["name"], :name => "name"
  add_index "forum_nodes", ["player_id"], :name => "player_id"

  create_table "forum_restrictions", :force => true do |t|
    t.integer "player_id",   :null => false
    t.integer "restriction", :null => false
    t.date    "expires"
    t.integer "given_by",    :null => false
  end

  add_index "forum_restrictions", ["given_by"], :name => "given_by"
  add_index "forum_restrictions", ["player_id", "expires", "restriction"], :name => "player_id_expires_restriction"
  add_index "forum_restrictions", ["player_id", "expires"], :name => "player_id_expires"
  add_index "forum_restrictions", ["player_id"], :name => "player_id"

  create_table "genocides", :force => true do |t|
    t.integer  "player_character_id", :null => false
    t.integer  "level",               :null => false
    t.datetime "when",                :null => false
    t.integer  "creature_id",         :null => false
    t.integer  "how_eliminated",      :null => false
  end

  add_index "genocides", ["creature_id"], :name => "creature_id"
  add_index "genocides", ["player_character_id"], :name => "player_character_id"

  create_table "healer_skills", :force => true do |t|
    t.integer "max_HP_restore"
    t.integer "max_MP_restore"
    t.integer "disease_id"
    t.float   "max_stat_restore"
    t.integer "min_sales",        :null => false
  end

  add_index "healer_skills", ["disease_id"], :name => "disease_id"
  add_index "healer_skills", ["min_sales"], :name => "min_sales"

  create_table "healing_spells", :force => true do |t|
    t.string  "name",            :limit => 32,  :default => "", :null => false
    t.string  "description",     :limit => 256
    t.integer "min_level"
    t.integer "min_heal"
    t.integer "max_heal"
    t.integer "disease_id"
    t.integer "mp_cost"
    t.boolean "cast_on_others?"
  end

  add_index "healing_spells", ["disease_id"], :name => "disease_id"
  add_index "healing_spells", ["min_level"], :name => "min_level"
  add_index "healing_spells", ["name"], :name => "name"

  create_table "healths", :force => true do |t|
    t.integer "HP",                     :default => 0,     :null => false
    t.integer "MP",                     :default => 0,     :null => false
    t.integer "base_HP",                :default => 0,     :null => false
    t.integer "base_MP",                :default => 0,     :null => false
    t.integer "wellness",               :default => 0,     :null => false
    t.integer "owner_id",                                  :null => false
    t.string  "kind",     :limit => 20, :default => "",    :null => false
    t.boolean "lock",                   :default => false
  end

  add_index "healths", ["kind", "owner_id"], :name => "kind_owner_id"

  create_table "illnesses", :force => true do |t|
    t.integer "owner_id",                                 :null => false
    t.integer "disease_id",                               :null => false
    t.integer "day",                      :default => 1
    t.string  "kind",       :limit => 20, :default => "", :null => false
  end

  add_index "illnesses", ["day"], :name => "day"
  add_index "illnesses", ["disease_id"], :name => "disease_id"
  add_index "illnesses", ["kind", "owner_id", "disease_id"], :name => "kind_owner_id_disease_id"
  add_index "illnesses", ["kind", "owner_id"], :name => "kind_owner_id"
  add_index "illnesses", ["owner_id"], :name => "owner_id"

  create_table "images", :force => true do |t|
    t.string  "image_text", :limit => 2500
    t.integer "player_id",                                     :null => false
    t.boolean "public",                     :default => false, :null => false
    t.integer "kingdom_id",                                    :null => false
    t.integer "image_type",                                    :null => false
    t.string  "picture",    :limit => 256
    t.string  "name",       :limit => 32,   :default => "",    :null => false
  end

  add_index "images", ["image_type"], :name => "type"
  add_index "images", ["kingdom_id"], :name => "kingdom_id"
  add_index "images", ["player_id"], :name => "player_id"

  create_table "inventories", :force => true do |t|
    t.integer "owner_id",                                  :null => false
    t.integer "item_id",                                   :null => false
    t.integer "quantity",               :default => 0,     :null => false
    t.string  "kind",     :limit => 20, :default => "",    :null => false
    t.boolean "lock",                   :default => false
  end

  add_index "inventories", ["item_id"], :name => "item_id"
  add_index "inventories", ["kind", "owner_id", "item_id"], :name => "kind_owner_id_item_id"
  add_index "inventories", ["kind", "owner_id"], :name => "kind_owner_id"
  add_index "inventories", ["owner_id"], :name => "owner_id"
  add_index "inventories", ["quantity"], :name => "quantity"

  create_table "items", :force => true do |t|
    t.string  "name",           :limit => 64,  :default => "", :null => false
    t.integer "equip_loc",                                     :null => false
    t.string  "description",    :limit => 256
    t.integer "base_item_id",                                  :null => false
    t.integer "min_level",                                     :null => false
    t.integer "c_class_id"
    t.integer "race_id"
    t.integer "race_body_type"
    t.integer "price"
    t.integer "npc_id"
  end

  add_index "items", ["base_item_id"], :name => "base_item_id"
  add_index "items", ["c_class_id"], :name => "c_class_id"
  add_index "items", ["min_level"], :name => "min_level"
  add_index "items", ["name"], :name => "name"
  add_index "items", ["npc_id", "base_item_id", "price"], :name => "npc_id_base_item_id_price"
  add_index "items", ["npc_id"], :name => "npc_id"
  add_index "items", ["race_body_type"], :name => "race_body_type"
  add_index "items", ["race_id"], :name => "race_id"

  create_table "kingdom_bans", :force => true do |t|
    t.integer "kingdom_id",                                        :null => false
    t.integer "player_character_id",                               :null => false
    t.string  "name",                :limit => 32, :default => "", :null => false
  end

  add_index "kingdom_bans", ["kingdom_id", "player_character_id"], :name => "kingdom_player_character_id"
  add_index "kingdom_bans", ["kingdom_id"], :name => "kingdom_id"
  add_index "kingdom_bans", ["name"], :name => "name"
  add_index "kingdom_bans", ["player_character_id"], :name => "player_character_id"

  create_table "kingdom_empty_shops", :force => true do |t|
    t.integer "kingdom_id",   :null => false
    t.integer "level_map_id", :null => false
  end

  add_index "kingdom_empty_shops", ["kingdom_id", "level_map_id"], :name => "kingdom_id_level_id"
  add_index "kingdom_empty_shops", ["kingdom_id"], :name => "kingdom_id"
  add_index "kingdom_empty_shops", ["level_map_id"], :name => "level_map_id"

  create_table "kingdom_entries", :force => true do |t|
    t.integer "kingdom_id",    :null => false
    t.integer "allowed_entry", :null => false
  end

  add_index "kingdom_entries", ["kingdom_id"], :name => "kingdom_id"

  create_table "kingdom_notices", :force => true do |t|
    t.integer  "kingdom_id",               :null => false
    t.integer  "shown_to",                 :null => false
    t.text     "text"
    t.string   "signed",     :limit => 64
    t.datetime "created_at"
  end

  add_index "kingdom_notices", ["kingdom_id", "shown_to"], :name => "kingdom_shown_to_id"
  add_index "kingdom_notices", ["kingdom_id"], :name => "kingdom_datetime_id"
  add_index "kingdom_notices", ["kingdom_id"], :name => "kingdom_id"
  add_index "kingdom_notices", ["signed"], :name => "signed"

  create_table "kingdoms", :force => true do |t|
    t.string  "name",                :limit => 32, :default => "",    :null => false
    t.integer "player_character_id"
    t.integer "num_of_pc"
    t.float   "tax_rate",                          :default => 5.0
    t.integer "num_peasants",                                         :null => false
    t.integer "gold",                              :default => 0,     :null => false
    t.integer "world_id",                                             :null => false
    t.integer "bigx",                                                 :null => false
    t.integer "bigy",                                                 :null => false
    t.integer "housing_cap",                       :default => 0,     :null => false
    t.boolean "lock",                              :default => false
  end

  add_index "kingdoms", ["name"], :name => "name"
  add_index "kingdoms", ["num_of_pc"], :name => "num_of_pc"
  add_index "kingdoms", ["num_peasants"], :name => "num_peasants"
  add_index "kingdoms", ["player_character_id"], :name => "player_character_id"
  add_index "kingdoms", ["tax_rate"], :name => "tax_rate"
  add_index "kingdoms", ["world_id"], :name => "world_id"

  create_table "level_maps", :force => true do |t|
    t.integer "level_id",                      :null => false
    t.integer "xpos",                          :null => false
    t.integer "ypos",                          :null => false
    t.integer "feature_id"
    t.boolean "lock",       :default => false
  end

  add_index "level_maps", ["feature_id"], :name => "feature_id"
  add_index "level_maps", ["level_id", "xpos", "ypos"], :name => "level_id_x_y"
  add_index "level_maps", ["level_id"], :name => "level_id"

  create_table "levels", :force => true do |t|
    t.integer "kingdom_id", :null => false
    t.integer "level",      :null => false
    t.integer "maxx",       :null => false
    t.integer "maxy",       :null => false
  end

  add_index "levels", ["kingdom_id", "level"], :name => "kingdom_level_id"
  add_index "levels", ["kingdom_id"], :name => "kingdom_id"

  create_table "log_quest_reqs", :force => true do |t|
    t.integer "log_quest_id",                               :null => false
    t.integer "owner_id",                                   :null => false
    t.integer "quest_req_id",                               :null => false
    t.integer "quantity",                   :default => 1
    t.string  "detail"
    t.string  "kind",         :limit => 20, :default => "", :null => false
  end

  add_index "log_quest_reqs", ["kind", "owner_id", "log_quest_id"], :name => "kind_owner_id_log_quest_id"
  add_index "log_quest_reqs", ["kind", "owner_id", "quest_req_id"], :name => "kind_owner_id_quest_req_id"
  add_index "log_quest_reqs", ["kind", "owner_id"], :name => "kind_owner_id"
  add_index "log_quest_reqs", ["log_quest_id"], :name => "log_quest_id"
  add_index "log_quest_reqs", ["owner_id"], :name => "owner_id"
  add_index "log_quest_reqs", ["quest_req_id"], :name => "quest_req_id"

  create_table "log_quests", :force => true do |t|
    t.integer "player_character_id",                    :null => false
    t.integer "quest_id",                               :null => false
    t.boolean "completed",           :default => false, :null => false
    t.boolean "rewarded",            :default => false, :null => false
  end

  add_index "log_quests", ["player_character_id", "quest_id", "completed"], :name => "player_character_quest_comp_id"
  add_index "log_quests", ["player_character_id", "quest_id"], :name => "player_character_quest_id"
  add_index "log_quests", ["player_character_id"], :name => "player_character_id"
  add_index "log_quests", ["quest_id"], :name => "quest_id"

  create_table "name_surfixes", :force => true do |t|
    t.string "name_surfixes", :limit => 32
  end

  create_table "name_titles", :force => true do |t|
    t.string  "title",  :limit => 32
    t.string  "stat",   :limit => 3
    t.integer "points"
  end

  add_index "name_titles", ["points"], :name => "points"
  add_index "name_titles", ["stat", "points"], :name => "stat_points"
  add_index "name_titles", ["stat", "title"], :name => "stat_title"

  create_table "names", :force => true do |t|
    t.string "name", :limit => 32
  end

  create_table "nonplayer_character_killers", :force => true do |t|
    t.integer  "player_character_id", :null => false
    t.integer  "npc_id"
    t.datetime "created_at"
  end

  add_index "nonplayer_character_killers", ["npc_id"], :name => "npc_id"
  add_index "nonplayer_character_killers", ["player_character_id", "npc_id"], :name => "player_character_npc_id"
  add_index "nonplayer_character_killers", ["player_character_id"], :name => "player_character_id"

  create_table "npc_blacksmith_items", :force => true do |t|
    t.integer "npc_id",    :null => false
    t.integer "item_id",   :null => false
    t.integer "min_sales"
  end

  add_index "npc_blacksmith_items", ["item_id"], :name => "item_id"
  add_index "npc_blacksmith_items", ["npc_id"], :name => "npc_id"

  create_table "npc_merchants", :force => true do |t|
    t.integer "npc_id",                              :null => false
    t.integer "healing_sales"
    t.integer "blacksmith_sales"
    t.integer "trainer_sales"
    t.boolean "consignor",        :default => false
    t.integer "race_body_type",                      :null => false
    t.boolean "lock",             :default => false
  end

  add_index "npc_merchants", ["npc_id"], :name => "npc_id"

  create_table "npcs", :force => true do |t|
    t.string  "name",         :limit => 32, :default => "",    :null => false
    t.integer "kingdom_id"
    t.integer "npc_division",                                  :null => false
    t.integer "gold",                       :default => 10,    :null => false
    t.integer "experience",                 :default => 10,    :null => false
    t.boolean "is_hired",                   :default => false, :null => false
    t.integer "image_id",                   :default => 1,     :null => false
    t.boolean "lock",                       :default => false
  end

  add_index "npcs", ["is_hired"], :name => "is_hired"
  add_index "npcs", ["kingdom_id", "npc_division"], :name => "kingdom_id_npc_division"
  add_index "npcs", ["kingdom_id"], :name => "kingdom_id"
  add_index "npcs", ["name", "is_hired"], :name => "name_is_hired"
  add_index "npcs", ["name"], :name => "name"

  create_table "player_character_equip_locs", :force => true do |t|
    t.integer "player_character_id", :null => false
    t.integer "equip_loc",           :null => false
    t.integer "item_id"
  end

  add_index "player_character_equip_locs", ["item_id"], :name => "FK_player_character_equip_locs_items"
  add_index "player_character_equip_locs", ["player_character_id", "equip_loc"], :name => "player_character_equip_loc"
  add_index "player_character_equip_locs", ["player_character_id"], :name => "player_character_id"

  create_table "player_character_killers", :force => true do |t|
    t.integer  "player_character_id", :null => false
    t.integer  "killed_id",           :null => false
    t.datetime "created_at"
  end

  add_index "player_character_killers", ["killed_id"], :name => "killed_id"
  add_index "player_character_killers", ["player_character_id", "killed_id"], :name => "player_character_killed_id"
  add_index "player_character_killers", ["player_character_id"], :name => "player_character_id"

  create_table "player_characters", :force => true do |t|
    t.string  "name",          :limit => 32, :default => "",    :null => false
    t.integer "player_id",                                      :null => false
    t.integer "c_class_id",                                     :null => false
    t.integer "race_id",                                        :null => false
    t.integer "level",                       :default => 0,     :null => false
    t.integer "next_level_at",               :default => 0,     :null => false
    t.integer "experience",                  :default => 0,     :null => false
    t.integer "kingdom_id"
    t.integer "house_x",                     :default => 0,     :null => false
    t.integer "house_y",                     :default => 0,     :null => false
    t.integer "turns",                       :default => 0,     :null => false
    t.integer "freepts",                     :default => 0,     :null => false
    t.integer "gold",                        :default => 0
    t.integer "image_id"
    t.integer "char_stat",                   :default => 1,     :null => false
    t.integer "in_kingdom"
    t.integer "bigx"
    t.integer "bigy"
    t.integer "kingdom_level"
    t.integer "in_world"
    t.boolean "lock",                        :default => false
  end

  add_index "player_characters", ["c_class_id"], :name => "c_class_id"
  add_index "player_characters", ["image_id"], :name => "image_id"
  add_index "player_characters", ["in_kingdom"], :name => "in_kingdom"
  add_index "player_characters", ["in_world"], :name => "in_world"
  add_index "player_characters", ["kingdom_id"], :name => "kingdom_id"
  add_index "player_characters", ["kingdom_level"], :name => "kingdom_level"
  add_index "player_characters", ["name"], :name => "name"
  add_index "player_characters", ["player_id"], :name => "player_id"
  add_index "player_characters", ["race_id"], :name => "race_id"

  create_table "players", :force => true do |t|
    t.string  "handle",              :limit => 32,  :default => "",    :null => false
    t.string  "passwd",              :limit => 256, :default => "",    :null => false
    t.string  "city",                :limit => 32,  :default => ""
    t.string  "state",               :limit => 2,   :default => ""
    t.string  "country",             :limit => 32,  :default => ""
    t.string  "email",               :limit => 64,  :default => ""
    t.string  "AIM",                 :limit => 32,  :default => ""
    t.string  "yahoo_sn",            :limit => 32,  :default => ""
    t.text    "bio"
    t.integer "account_status",                     :default => 1,     :null => false
    t.boolean "admin",                              :default => false
    t.boolean "table_editor_access",                :default => false
    t.integer "mod_level",                          :default => 0
    t.date    "joined"
  end

  add_index "players", ["city"], :name => "city"
  add_index "players", ["country"], :name => "country"
  add_index "players", ["handle"], :name => "handle"
  add_index "players", ["state"], :name => "state"

  create_table "pref_lists", :force => true do |t|
    t.integer "kingdom_id",               :null => false
    t.integer "thing_id",                 :null => false
    t.string  "kind",       :limit => 20
  end

  add_index "pref_lists", ["kind"], :name => "kind"
  add_index "pref_lists", ["kingdom_id"], :name => "kingdom_id"
  add_index "pref_lists", ["kingdom_id"], :name => "kingdom_id_pref_list_type"
  add_index "pref_lists", ["thing_id"], :name => "thing_id"

  create_table "quest_reqs", :force => true do |t|
    t.integer "quest_id",                               :null => false
    t.integer "quantity"
    t.string  "detail"
    t.string  "kind",     :limit => 20, :default => "", :null => false
  end

  add_index "quest_reqs", ["quest_id", "kind"], :name => "quest_id_kind"
  add_index "quest_reqs", ["quest_id"], :name => "quest_id"

  create_table "quests", :force => true do |t|
    t.string  "name",             :limit => 32,  :default => "",  :null => false
    t.string  "description",      :limit => 256
    t.integer "kingdom_id",                                       :null => false
    t.integer "player_id",                                        :null => false
    t.integer "max_level",                       :default => 500
    t.integer "max_completeable"
    t.integer "quest_status",                                     :null => false
    t.integer "gold"
    t.integer "item_id"
    t.integer "quest_id"
  end

  add_index "quests", ["id", "quest_status"], :name => "id_status"
  add_index "quests", ["item_id"], :name => "item_id"
  add_index "quests", ["kingdom_id", "name"], :name => "name"
  add_index "quests", ["kingdom_id", "quest_status", "name"], :name => "kingdom_id_quest_status_name"
  add_index "quests", ["kingdom_id", "quest_status"], :name => "kingdom_id_quest_status"
  add_index "quests", ["kingdom_id"], :name => "kingdom_id"
  add_index "quests", ["player_id"], :name => "player_id"
  add_index "quests", ["quest_id"], :name => "quest_id"

  create_table "race_equip_locs", :force => true do |t|
    t.integer "race_id",   :null => false
    t.integer "equip_loc", :null => false
  end

  add_index "race_equip_locs", ["equip_loc"], :name => "equip_loc"
  add_index "race_equip_locs", ["race_id"], :name => "race_id"

  create_table "races", :force => true do |t|
    t.string  "name",           :limit => 32,  :default => "",  :null => false
    t.string  "description",    :limit => 256
    t.integer "kingdom_id"
    t.integer "race_body_type",                                 :null => false
    t.integer "freepts",                                        :null => false
    t.integer "image_id",                      :default => 140
  end

  add_index "races", ["kingdom_id"], :name => "kingdom_id"
  add_index "races", ["name"], :name => "name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :default => "", :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "stats", :force => true do |t|
    t.integer "con",                    :default => 0,     :null => false
    t.integer "dam",                    :default => 0,     :null => false
    t.integer "dex",                    :default => 0,     :null => false
    t.integer "dfn",                    :default => 0,     :null => false
    t.integer "int",                    :default => 0,     :null => false
    t.integer "mag",                    :default => 0,     :null => false
    t.integer "str",                    :default => 0,     :null => false
    t.integer "owner_id",                                  :null => false
    t.string  "kind",     :limit => 20, :default => "",    :null => false
    t.boolean "lock",                   :default => false
  end

  add_index "stats", ["kind", "owner_id"], :name => "kind_owner_id"

  create_table "system_statuses", :force => true do |t|
    t.integer "status"
    t.integer "days"
  end

  create_table "table_locks", :force => true do |t|
    t.string  "name", :limit => 32, :default => "",    :null => false
    t.boolean "lock",               :default => false
  end

  add_index "table_locks", ["name"], :name => "name"

  create_table "trainer_skills", :force => true do |t|
    t.float   "max_skill_taught", :null => false
    t.integer "min_sales",        :null => false
  end

  add_index "trainer_skills", ["min_sales"], :name => "min_sales"

  create_table "world_maps", :force => true do |t|
    t.integer "world_id",                      :null => false
    t.integer "xpos",                          :null => false
    t.integer "ypos",                          :null => false
    t.integer "bigxpos",                       :null => false
    t.integer "bigypos",                       :null => false
    t.integer "feature_id"
    t.boolean "lock",       :default => false
  end

  add_index "world_maps", ["feature_id"], :name => "feature_id"
  add_index "world_maps", ["world_id", "bigxpos", "bigypos", "xpos", "ypos"], :name => "world_bixs_bigy_x_y_id"
  add_index "world_maps", ["world_id", "bigxpos", "bigypos"], :name => "world_id_bigxpos_bigypos"
  add_index "world_maps", ["world_id"], :name => "world_id"

  create_table "worlds", :force => true do |t|
    t.string  "name",    :limit => 32,   :default => "", :null => false
    t.integer "minbigx",                                 :null => false
    t.integer "minbigy",                                 :null => false
    t.integer "maxbigx",                                 :null => false
    t.integer "maxbigy",                                 :null => false
    t.integer "maxx",                                    :null => false
    t.integer "maxy",                                    :null => false
    t.string  "text",    :limit => 1000
  end

  add_index "worlds", ["name"], :name => "name"

end
