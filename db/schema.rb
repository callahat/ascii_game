# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180707204451) do

  create_table "attack_spells", force: :cascade do |t|
    t.string   "name",         limit: 32,  default: "", null: false
    t.string   "description",  limit: 256
    t.integer  "min_level",    limit: 4,                null: false
    t.integer  "min_dam",      limit: 4,                null: false
    t.integer  "max_dam",      limit: 4,                null: false
    t.integer  "dam_from_mag", limit: 4,                null: false
    t.integer  "dam_from_int", limit: 4,                null: false
    t.integer  "mp_cost",      limit: 4,                null: false
    t.integer  "hp_cost",      limit: 4,                null: false
    t.boolean  "splash",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attack_spells", ["min_level"], name: "min_level", using: :btree
  add_index "attack_spells", ["name"], name: "name", using: :btree

  create_table "base_items", force: :cascade do |t|
    t.string   "name",           limit: 32,  default: "", null: false
    t.string   "description",    limit: 256
    t.integer  "equip_loc",      limit: 4,                null: false
    t.integer  "price",          limit: 4,                null: false
    t.integer  "race_body_type", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "base_items", ["name"], name: "name", using: :btree
  add_index "base_items", ["price", "race_body_type"], name: "price_race_body_type", using: :btree
  add_index "base_items", ["price"], name: "price", using: :btree
  add_index "base_items", ["race_body_type"], name: "race_body_type", using: :btree

  create_table "battle_enemies", force: :cascade do |t|
    t.integer "battle_id",       limit: 4,                null: false
    t.integer "battle_group_id", limit: 4,                null: false
    t.integer "enemy_id",        limit: 4,                null: false
    t.string  "special",         limit: 20, default: "0"
    t.string  "kind",            limit: 20, default: "",  null: false
  end

  add_index "battle_enemies", ["battle_id", "battle_group_id", "kind", "special"], name: "battle_id_battle_group_id_kind_special", using: :btree
  add_index "battle_enemies", ["battle_id", "battle_group_id", "kind"], name: "battle_id_battle_group_id_kind", using: :btree
  add_index "battle_enemies", ["battle_id", "battle_group_id"], name: "battle_id_battle_group_id", using: :btree
  add_index "battle_enemies", ["battle_id", "kind"], name: "battle_id_kind", using: :btree
  add_index "battle_enemies", ["battle_id"], name: "battle_id", using: :btree
  add_index "battle_enemies", ["enemy_id"], name: "enemy_id", using: :btree

  create_table "battle_groups", force: :cascade do |t|
    t.integer "battle_id", limit: 4,                null: false
    t.string  "name",      limit: 255, default: "", null: false
  end

  add_index "battle_groups", ["battle_id"], name: "battle_id", using: :btree

  create_table "battle_items", force: :cascade do |t|
    t.integer "battle_id", limit: 4, null: false
    t.integer "item_id",   limit: 4, null: false
    t.integer "quantity",  limit: 4, null: false
  end

  add_index "battle_items", ["battle_id"], name: "battle_id", using: :btree
  add_index "battle_items", ["item_id"], name: "item_id", using: :btree

  create_table "battles", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4,             null: false
    t.integer  "gold",       limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "battles", ["owner_id"], name: "owner_id", using: :btree

  create_table "blacksmith_skills", force: :cascade do |t|
    t.integer  "base_item_id", limit: 4, null: false
    t.integer  "min_sales",    limit: 4, null: false
    t.integer  "min_mod",      limit: 4, null: false
    t.integer  "max_mod",      limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacksmith_skills", ["base_item_id"], name: "base_item_id", using: :btree
  add_index "blacksmith_skills", ["min_sales"], name: "min_sales", using: :btree

  create_table "c_classes", force: :cascade do |t|
    t.string   "name",           limit: 32,  default: "", null: false
    t.string   "description",    limit: 256
    t.boolean  "attack_spells"
    t.boolean  "healing_spells"
    t.integer  "freepts",        limit: 4,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "c_classes", ["name"], name: "name", using: :btree

  create_table "creature_kills", force: :cascade do |t|
    t.integer  "player_character_id", limit: 4,             null: false
    t.integer  "creature_id",         limit: 4,             null: false
    t.integer  "number",              limit: 4, default: 0, null: false
    t.datetime "updated_at"
  end

  add_index "creature_kills", ["creature_id"], name: "creature_id", using: :btree
  add_index "creature_kills", ["player_character_id", "creature_id"], name: "player_character_creature_id", using: :btree
  add_index "creature_kills", ["player_character_id"], name: "player_character_id", using: :btree

  create_table "creatures", force: :cascade do |t|
    t.string   "name",         limit: 32,  default: "",    null: false
    t.string   "description",  limit: 256
    t.integer  "experience",   limit: 4,                   null: false
    t.integer  "HP",           limit: 4,                   null: false
    t.integer  "gold",         limit: 4,                   null: false
    t.integer  "image_id",     limit: 4,                   null: false
    t.integer  "player_id",    limit: 4,                   null: false
    t.boolean  "public",                   default: false, null: false
    t.integer  "kingdom_id",   limit: 4,                   null: false
    t.integer  "number_alive", limit: 4,                   null: false
    t.float    "fecundity",    limit: 24,                  null: false
    t.integer  "disease_id",   limit: 4
    t.boolean  "armed",                    default: false
    t.integer  "being_fought", limit: 4,   default: 0
    t.boolean  "lock",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "creatures", ["disease_id"], name: "disease_id", using: :btree
  add_index "creatures", ["experience"], name: "experience", using: :btree
  add_index "creatures", ["image_id"], name: "FK_creatures_images", using: :btree
  add_index "creatures", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "creatures", ["name"], name: "name", using: :btree
  add_index "creatures", ["player_id"], name: "player_id", using: :btree
  add_index "creatures", ["public"], name: "public", using: :btree

  create_table "current_events", force: :cascade do |t|
    t.integer  "player_character_id", limit: 4,                null: false
    t.integer  "event_id",            limit: 4
    t.integer  "location_id",         limit: 4,                null: false
    t.integer  "priority",            limit: 4,   default: 0,  null: false
    t.integer  "completed",           limit: 4,   default: -1
    t.string   "kind",                limit: 255,              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "current_events", ["event_id"], name: "event_id", using: :btree
  add_index "current_events", ["kind", "event_id", "location_id"], name: "kind_event_id_location_id", using: :btree
  add_index "current_events", ["kind", "player_character_id", "event_id", "location_id"], name: "kind_player_character_id_event_id_location_id", using: :btree
  add_index "current_events", ["kind"], name: "kind", using: :btree
  add_index "current_events", ["location_id"], name: "location_id", using: :btree
  add_index "current_events", ["player_character_id", "kind"], name: "player_character_id_kind", using: :btree
  add_index "current_events", ["player_character_id"], name: "player_character_id", using: :btree

  create_table "diseases", force: :cascade do |t|
    t.string   "name",             limit: 32,  default: "", null: false
    t.string   "description",      limit: 256
    t.float    "virility",         limit: 24,               null: false
    t.integer  "trans_method",     limit: 4,                null: false
    t.integer  "HP_per_turn",      limit: 4
    t.integer  "MP_per_turn",      limit: 4
    t.boolean  "NPC_fatal"
    t.float    "peasant_fatality", limit: 24
    t.integer  "min_peasants",     limit: 4,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diseases", ["name"], name: "name", using: :btree

  create_table "done_events", force: :cascade do |t|
    t.integer  "event_id",            limit: 4,   null: false
    t.integer  "player_character_id", limit: 4,   null: false
    t.integer  "location_id",         limit: 4,   null: false
    t.string   "kind",                limit: 255, null: false
    t.datetime "created_at"
  end

  add_index "done_events", ["event_id", "player_character_id"], name: "event_id_player_character_id", using: :btree
  add_index "done_events", ["event_id", "player_character_id"], name: "event_id_player_id_level_map_id", using: :btree
  add_index "done_events", ["event_id"], name: "event_id", using: :btree
  add_index "done_events", ["kind", "player_character_id", "location_id", "event_id"], name: "kind_player_character_id_location_id_event_id", using: :btree
  add_index "done_events", ["kind", "player_character_id", "location_id"], name: "kind_player_character_id_location_id", using: :btree
  add_index "done_events", ["kind"], name: "kind", using: :btree
  add_index "done_events", ["location_id"], name: "location_id", using: :btree
  add_index "done_events", ["player_character_id"], name: "player_character_id", using: :btree
  add_index "done_events", ["player_character_id"], name: "player_character_id_world_map_id", using: :btree

  create_table "done_quests", force: :cascade do |t|
    t.integer  "quest_id",            limit: 4, null: false
    t.integer  "player_character_id", limit: 4, null: false
    t.datetime "created_at",                    null: false
  end

  add_index "done_quests", ["player_character_id"], name: "player_character_id", using: :btree
  add_index "done_quests", ["quest_id", "player_character_id"], name: "quest_id_player_character_id", using: :btree
  add_index "done_quests", ["quest_id"], name: "quest_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "kingdom_id",     limit: 4,                     null: false
    t.integer  "player_id",      limit: 4,                     null: false
    t.integer  "event_rep_type", limit: 4,                     null: false
    t.integer  "event_reps",     limit: 4
    t.string   "name",           limit: 64,    default: "",    null: false
    t.boolean  "armed",                        default: false
    t.integer  "cost",           limit: 4,                     null: false
    t.text     "text",           limit: 65535
    t.string   "kind",           limit: 20
    t.integer  "thing_id",       limit: 4
    t.string   "flex",           limit: 256
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["armed", "kind", "kingdom_id"], name: "armed_kind_kingdom_id", using: :btree
  add_index "events", ["armed", "kind", "player_id"], name: "armed_kind_player_id", using: :btree
  add_index "events", ["armed", "kingdom_id"], name: "armed_kingdom_id", using: :btree
  add_index "events", ["armed", "player_id"], name: "armed_player_id", using: :btree
  add_index "events", ["kind", "kingdom_id"], name: "kind_kingdom_id", using: :btree
  add_index "events", ["kind", "player_id"], name: "kind_player_id", using: :btree
  add_index "events", ["kind"], name: "kind", using: :btree
  add_index "events", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "events", ["player_id"], name: "player_id", using: :btree

  create_table "feature_events", force: :cascade do |t|
    t.integer  "feature_id", limit: 4,                  null: false
    t.integer  "event_id",   limit: 4,                  null: false
    t.float    "chance",     limit: 24, default: 100.0, null: false
    t.integer  "priority",   limit: 4
    t.boolean  "choice",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_events", ["event_id"], name: "event_id", using: :btree
  add_index "feature_events", ["feature_id", "priority", "choice"], name: "feature_id_priority_choice", using: :btree
  add_index "feature_events", ["feature_id", "priority"], name: "feature_priority_id", using: :btree
  add_index "feature_events", ["feature_id"], name: "feature_id", using: :btree

  create_table "features", force: :cascade do |t|
    t.string   "name",             limit: 64
    t.string   "description",      limit: 256
    t.integer  "action_cost",      limit: 4
    t.integer  "image_id",         limit: 4,                   null: false
    t.integer  "player_id",        limit: 4,                   null: false
    t.boolean  "world_feature"
    t.integer  "kingdom_id",       limit: 4,                   null: false
    t.boolean  "public"
    t.integer  "cost",             limit: 4
    t.integer  "num_occupants",    limit: 4,   default: 0,     null: false
    t.boolean  "armed",                        default: false
    t.integer  "store_front_size", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "features", ["armed", "world_feature", "name"], name: "armed_wrold_feature_name", using: :btree
  add_index "features", ["image_id"], name: "image_id", using: :btree
  add_index "features", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "features", ["name"], name: "name", using: :btree
  add_index "features", ["player_id"], name: "player_id", using: :btree
  add_index "features", ["world_feature", "kingdom_id", "public"], name: "kingdom_id_public_world", using: :btree
  add_index "features", ["world_feature", "kingdom_id"], name: "world_feature_kingdom_id", using: :btree
  add_index "features", ["world_feature", "public"], name: "world_feature_public", using: :btree

  create_table "forum_nodes", force: :cascade do |t|
    t.integer  "player_id",     limit: 4,                     null: false
    t.integer  "forum_node_id", limit: 4
    t.string   "name",          limit: 64
    t.text     "text",          limit: 65535
    t.datetime "created_at"
    t.boolean  "is_locked",                   default: false
    t.boolean  "is_hidden",                   default: false
    t.boolean  "is_deleted",                  default: false
    t.boolean  "is_mods_only",                default: false
    t.integer  "elders",        limit: 4,     default: 0,     null: false
    t.text     "edit_notices",  limit: 65535
    t.datetime "updated_at"
    t.string   "kind",          limit: 20
    t.boolean  "lock"
    t.integer  "post_count",    limit: 4,     default: 0
    t.integer  "last_post_id",  limit: 4
  end

  add_index "forum_nodes", ["kind", "forum_node_id", "is_deleted"], name: "kind_forum_node_id_is_deleted", using: :btree
  add_index "forum_nodes", ["kind", "forum_node_id", "is_hidden"], name: "kind_forum_node_id_is_hidden", using: :btree
  add_index "forum_nodes", ["kind", "forum_node_id", "is_locked"], name: "kind_forum_node_id_is_locked", using: :btree
  add_index "forum_nodes", ["kind", "forum_node_id", "is_mods_only"], name: "kind_forum_node_id_is_mods_only", using: :btree
  add_index "forum_nodes", ["kind", "forum_node_id"], name: "kind_forum_node_id", using: :btree
  add_index "forum_nodes", ["kind"], name: "index_forum_nodes_on_kind", using: :btree
  add_index "forum_nodes", ["player_id"], name: "player_id", using: :btree

  create_table "forum_restrictions", force: :cascade do |t|
    t.integer  "player_id",   limit: 4, null: false
    t.integer  "restriction", limit: 4, null: false
    t.date     "expires"
    t.integer  "given_by",    limit: 4, null: false
    t.datetime "created_at"
  end

  add_index "forum_restrictions", ["given_by"], name: "given_by", using: :btree
  add_index "forum_restrictions", ["player_id", "expires", "restriction"], name: "player_id_expires_restriction", using: :btree
  add_index "forum_restrictions", ["player_id", "expires"], name: "player_id_expires", using: :btree
  add_index "forum_restrictions", ["player_id"], name: "player_id", using: :btree

  create_table "forum_user_attributes", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "mod_level",  limit: 4
    t.integer  "posts",      limit: 4
    t.boolean  "lock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forum_user_attributes", ["posts"], name: "index_forum_user_attributes_on_posts", using: :btree
  add_index "forum_user_attributes", ["user_id"], name: "index_forum_user_attributes_on_user_id", using: :btree

  create_table "genocides", force: :cascade do |t|
    t.integer  "player_character_id", limit: 4, null: false
    t.integer  "level",               limit: 4, null: false
    t.datetime "when",                          null: false
    t.integer  "creature_id",         limit: 4, null: false
    t.integer  "how_eliminated",      limit: 4, null: false
  end

  add_index "genocides", ["creature_id"], name: "creature_id", using: :btree
  add_index "genocides", ["player_character_id"], name: "player_character_id", using: :btree

  create_table "healer_skills", force: :cascade do |t|
    t.integer  "max_HP_restore",   limit: 4
    t.integer  "max_MP_restore",   limit: 4
    t.integer  "disease_id",       limit: 4
    t.float    "max_stat_restore", limit: 24
    t.integer  "min_sales",        limit: 4,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "healer_skills", ["disease_id"], name: "disease_id", using: :btree
  add_index "healer_skills", ["min_sales"], name: "min_sales", using: :btree

  create_table "healing_spells", force: :cascade do |t|
    t.string   "name",           limit: 32,  default: "", null: false
    t.string   "description",    limit: 256
    t.integer  "min_level",      limit: 4
    t.integer  "min_heal",       limit: 4
    t.integer  "max_heal",       limit: 4
    t.integer  "disease_id",     limit: 4
    t.integer  "mp_cost",        limit: 4
    t.boolean  "cast_on_others"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "healing_spells", ["disease_id"], name: "disease_id", using: :btree
  add_index "healing_spells", ["min_level"], name: "min_level", using: :btree
  add_index "healing_spells", ["name"], name: "name", using: :btree

  create_table "healths", force: :cascade do |t|
    t.integer  "HP",         limit: 4,  default: 0,     null: false
    t.integer  "MP",         limit: 4,  default: 0,     null: false
    t.integer  "base_HP",    limit: 4,  default: 0,     null: false
    t.integer  "base_MP",    limit: 4,  default: 0,     null: false
    t.integer  "wellness",   limit: 4,  default: 0,     null: false
    t.integer  "owner_id",   limit: 4,                  null: false
    t.string   "kind",       limit: 20, default: "",    null: false
    t.boolean  "lock",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "healths", ["kind", "owner_id"], name: "kind_owner_id", using: :btree

  create_table "illnesses", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4,               null: false
    t.integer  "disease_id", limit: 4,               null: false
    t.integer  "day",        limit: 4,  default: 1
    t.string   "kind",       limit: 20, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "illnesses", ["day"], name: "day", using: :btree
  add_index "illnesses", ["disease_id"], name: "disease_id", using: :btree
  add_index "illnesses", ["kind", "owner_id", "disease_id"], name: "kind_owner_id_disease_id", using: :btree
  add_index "illnesses", ["kind", "owner_id"], name: "kind_owner_id", using: :btree
  add_index "illnesses", ["owner_id"], name: "owner_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "image_text", limit: 2500
    t.integer  "player_id",  limit: 4,                    null: false
    t.boolean  "public",                  default: false, null: false
    t.integer  "kingdom_id", limit: 4,                    null: false
    t.integer  "image_type", limit: 4,                    null: false
    t.string   "picture",    limit: 256
    t.string   "name",       limit: 64,   default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["image_type"], name: "type", using: :btree
  add_index "images", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "images", ["player_id"], name: "player_id", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4,                  null: false
    t.integer  "item_id",    limit: 4,                  null: false
    t.integer  "quantity",   limit: 4,  default: 0,     null: false
    t.string   "kind",       limit: 20, default: "",    null: false
    t.boolean  "lock",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventories", ["item_id"], name: "item_id", using: :btree
  add_index "inventories", ["kind", "owner_id", "item_id"], name: "kind_owner_id_item_id", using: :btree
  add_index "inventories", ["kind", "owner_id"], name: "kind_owner_id", using: :btree
  add_index "inventories", ["owner_id"], name: "owner_id", using: :btree
  add_index "inventories", ["quantity"], name: "quantity", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name",           limit: 64,  default: "", null: false
    t.integer  "equip_loc",      limit: 4,                null: false
    t.string   "description",    limit: 256
    t.integer  "base_item_id",   limit: 4,                null: false
    t.integer  "min_level",      limit: 4,                null: false
    t.integer  "c_class_id",     limit: 4
    t.integer  "race_id",        limit: 4
    t.integer  "race_body_type", limit: 4
    t.integer  "price",          limit: 4
    t.integer  "npc_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["base_item_id"], name: "base_item_id", using: :btree
  add_index "items", ["c_class_id"], name: "c_class_id", using: :btree
  add_index "items", ["min_level"], name: "min_level", using: :btree
  add_index "items", ["name"], name: "name", using: :btree
  add_index "items", ["npc_id", "base_item_id", "price"], name: "npc_id_base_item_id_price", using: :btree
  add_index "items", ["npc_id"], name: "npc_id", using: :btree
  add_index "items", ["race_body_type"], name: "race_body_type", using: :btree
  add_index "items", ["race_id"], name: "race_id", using: :btree

  create_table "kingdom_bans", force: :cascade do |t|
    t.integer  "kingdom_id",          limit: 4,               null: false
    t.integer  "player_character_id", limit: 4,               null: false
    t.string   "name",                limit: 32, default: "", null: false
    t.datetime "created_at"
  end

  add_index "kingdom_bans", ["kingdom_id", "player_character_id"], name: "kingdom_player_character_id", using: :btree
  add_index "kingdom_bans", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "kingdom_bans", ["name"], name: "name", using: :btree
  add_index "kingdom_bans", ["player_character_id"], name: "player_character_id", using: :btree

  create_table "kingdom_empty_shops", force: :cascade do |t|
    t.integer "kingdom_id",   limit: 4, null: false
    t.integer "level_map_id", limit: 4, null: false
  end

  add_index "kingdom_empty_shops", ["kingdom_id", "level_map_id"], name: "kingdom_id_level_id", using: :btree
  add_index "kingdom_empty_shops", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "kingdom_empty_shops", ["level_map_id"], name: "level_map_id", using: :btree

  create_table "kingdom_entries", force: :cascade do |t|
    t.integer  "kingdom_id",    limit: 4, null: false
    t.integer  "allowed_entry", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kingdom_entries", ["kingdom_id"], name: "kingdom_id", using: :btree

  create_table "kingdom_notices", force: :cascade do |t|
    t.integer  "kingdom_id", limit: 4,     null: false
    t.integer  "shown_to",   limit: 4,     null: false
    t.text     "text",       limit: 65535
    t.string   "signed",     limit: 64
    t.datetime "created_at"
  end

  add_index "kingdom_notices", ["kingdom_id", "shown_to"], name: "kingdom_shown_to_id", using: :btree
  add_index "kingdom_notices", ["kingdom_id"], name: "kingdom_datetime_id", using: :btree
  add_index "kingdom_notices", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "kingdom_notices", ["signed"], name: "signed", using: :btree

  create_table "kingdoms", force: :cascade do |t|
    t.string   "name",                limit: 32, default: "",    null: false
    t.integer  "player_character_id", limit: 4
    t.integer  "num_of_pc",           limit: 4
    t.float    "tax_rate",            limit: 24, default: 5.0
    t.integer  "num_peasants",        limit: 4,                  null: false
    t.integer  "gold",                limit: 8,  default: 0,     null: false
    t.integer  "world_id",            limit: 4,                  null: false
    t.integer  "bigx",                limit: 4,                  null: false
    t.integer  "bigy",                limit: 4,                  null: false
    t.integer  "housing_cap",         limit: 4,  default: 0,     null: false
    t.boolean  "lock",                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kingdoms", ["name"], name: "name", using: :btree
  add_index "kingdoms", ["num_of_pc"], name: "num_of_pc", using: :btree
  add_index "kingdoms", ["num_peasants"], name: "num_peasants", using: :btree
  add_index "kingdoms", ["player_character_id"], name: "player_character_id", using: :btree
  add_index "kingdoms", ["tax_rate"], name: "tax_rate", using: :btree
  add_index "kingdoms", ["world_id"], name: "world_id", using: :btree

  create_table "level_maps", force: :cascade do |t|
    t.integer  "level_id",   limit: 4,                 null: false
    t.integer  "xpos",       limit: 4,                 null: false
    t.integer  "ypos",       limit: 4,                 null: false
    t.integer  "feature_id", limit: 4
    t.boolean  "lock",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "level_maps", ["feature_id"], name: "feature_id", using: :btree
  add_index "level_maps", ["level_id", "xpos", "ypos"], name: "level_id_x_y", using: :btree
  add_index "level_maps", ["level_id"], name: "level_id", using: :btree

  create_table "levels", force: :cascade do |t|
    t.integer  "kingdom_id", limit: 4, null: false
    t.integer  "level",      limit: 4, null: false
    t.integer  "maxx",       limit: 4, null: false
    t.integer  "maxy",       limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "levels", ["kingdom_id", "level"], name: "kingdom_level_id", using: :btree
  add_index "levels", ["kingdom_id"], name: "kingdom_id", using: :btree

  create_table "log_quest_reqs", force: :cascade do |t|
    t.integer  "log_quest_id", limit: 4,                null: false
    t.integer  "owner_id",     limit: 4,                null: false
    t.integer  "quest_req_id", limit: 4,                null: false
    t.integer  "quantity",     limit: 4,   default: 1
    t.string   "detail",       limit: 255
    t.string   "kind",         limit: 20,  default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_quest_reqs", ["kind", "owner_id", "log_quest_id"], name: "kind_owner_id_log_quest_id", using: :btree
  add_index "log_quest_reqs", ["kind", "owner_id", "quest_req_id"], name: "kind_owner_id_quest_req_id", using: :btree
  add_index "log_quest_reqs", ["kind", "owner_id"], name: "kind_owner_id", using: :btree
  add_index "log_quest_reqs", ["log_quest_id"], name: "log_quest_id", using: :btree
  add_index "log_quest_reqs", ["owner_id"], name: "owner_id", using: :btree
  add_index "log_quest_reqs", ["quest_req_id"], name: "quest_req_id", using: :btree

  create_table "log_quests", force: :cascade do |t|
    t.integer  "player_character_id", limit: 4,                 null: false
    t.integer  "quest_id",            limit: 4,                 null: false
    t.boolean  "completed",                     default: false, null: false
    t.boolean  "rewarded",                      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_quests", ["player_character_id", "quest_id", "completed"], name: "player_character_quest_comp_id", using: :btree
  add_index "log_quests", ["player_character_id", "quest_id"], name: "player_character_quest_id", using: :btree
  add_index "log_quests", ["player_character_id"], name: "player_character_id", using: :btree
  add_index "log_quests", ["quest_id"], name: "quest_id", using: :btree

  create_table "name_surfixes", force: :cascade do |t|
    t.string   "surfix",     limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "name_titles", force: :cascade do |t|
    t.string   "title",      limit: 32
    t.string   "stat",       limit: 3
    t.integer  "points",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "name_titles", ["points"], name: "points", using: :btree
  add_index "name_titles", ["stat", "points"], name: "stat_points", using: :btree
  add_index "name_titles", ["stat", "title"], name: "stat_title", using: :btree

  create_table "names", force: :cascade do |t|
    t.string   "name",       limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nonplayer_character_killers", force: :cascade do |t|
    t.integer  "player_character_id", limit: 4, null: false
    t.integer  "npc_id",              limit: 4
    t.datetime "created_at"
  end

  add_index "nonplayer_character_killers", ["npc_id"], name: "npc_id", using: :btree
  add_index "nonplayer_character_killers", ["player_character_id", "npc_id"], name: "player_character_npc_id", using: :btree
  add_index "nonplayer_character_killers", ["player_character_id"], name: "player_character_id", using: :btree

  create_table "npc_blacksmith_items", force: :cascade do |t|
    t.integer  "npc_id",     limit: 4, null: false
    t.integer  "item_id",    limit: 4, null: false
    t.integer  "min_sales",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "npc_blacksmith_items", ["item_id"], name: "item_id", using: :btree
  add_index "npc_blacksmith_items", ["npc_id"], name: "npc_id", using: :btree

  create_table "npc_merchant_details", force: :cascade do |t|
    t.integer  "npc_id",           limit: 4,                 null: false
    t.integer  "healing_sales",    limit: 8
    t.integer  "blacksmith_sales", limit: 8
    t.integer  "trainer_sales",    limit: 8
    t.boolean  "consignor",                  default: false
    t.integer  "race_body_type",   limit: 4,                 null: false
    t.boolean  "lock",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "npc_merchant_details", ["npc_id"], name: "npc_id", using: :btree

  create_table "npcs", force: :cascade do |t|
    t.string   "name",       limit: 32, default: "",    null: false
    t.integer  "kingdom_id", limit: 4
    t.integer  "gold",       limit: 4,  default: 10,    null: false
    t.integer  "experience", limit: 4,  default: 10,    null: false
    t.boolean  "is_hired",              default: false, null: false
    t.integer  "image_id",   limit: 4,  default: 1,     null: false
    t.boolean  "lock",                  default: false
    t.string   "kind",       limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "npcs", ["is_hired"], name: "is_hired", using: :btree
  add_index "npcs", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "npcs", ["kingdom_id"], name: "kingdom_id_npc_division", using: :btree
  add_index "npcs", ["name", "is_hired"], name: "name_is_hired", using: :btree
  add_index "npcs", ["name"], name: "name", using: :btree

  create_table "player_character_equip_locs", force: :cascade do |t|
    t.integer "player_character_id", limit: 4, null: false
    t.integer "equip_loc",           limit: 4, null: false
    t.integer "item_id",             limit: 4
  end

  add_index "player_character_equip_locs", ["item_id"], name: "FK_player_character_equip_locs_items", using: :btree
  add_index "player_character_equip_locs", ["player_character_id", "equip_loc"], name: "player_character_equip_loc", using: :btree
  add_index "player_character_equip_locs", ["player_character_id"], name: "player_character_id", using: :btree

  create_table "player_character_killers", force: :cascade do |t|
    t.integer  "player_character_id", limit: 4, null: false
    t.integer  "killed_id",           limit: 4, null: false
    t.datetime "created_at"
  end

  add_index "player_character_killers", ["killed_id"], name: "killed_id", using: :btree
  add_index "player_character_killers", ["player_character_id", "killed_id"], name: "player_character_killed_id", using: :btree
  add_index "player_character_killers", ["player_character_id"], name: "player_character_id", using: :btree

  create_table "player_characters", force: :cascade do |t|
    t.string   "name",          limit: 32, default: "",    null: false
    t.integer  "player_id",     limit: 4,                  null: false
    t.integer  "c_class_id",    limit: 4,                  null: false
    t.integer  "race_id",       limit: 4,                  null: false
    t.integer  "level",         limit: 4,  default: 0,     null: false
    t.integer  "next_level_at", limit: 4,  default: 0,     null: false
    t.integer  "experience",    limit: 4,  default: 0,     null: false
    t.integer  "kingdom_id",    limit: 4
    t.integer  "house_x",       limit: 4,  default: 0,     null: false
    t.integer  "house_y",       limit: 4,  default: 0,     null: false
    t.integer  "turns",         limit: 4,  default: 0,     null: false
    t.integer  "freepts",       limit: 4,  default: 0,     null: false
    t.integer  "gold",          limit: 8,  default: 0
    t.integer  "image_id",      limit: 4
    t.integer  "char_stat",     limit: 4,  default: 1,     null: false
    t.integer  "in_kingdom",    limit: 4
    t.integer  "bigx",          limit: 4
    t.integer  "bigy",          limit: 4
    t.integer  "kingdom_level", limit: 4
    t.integer  "in_world",      limit: 4
    t.boolean  "lock",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "player_characters", ["c_class_id"], name: "c_class_id", using: :btree
  add_index "player_characters", ["image_id"], name: "image_id", using: :btree
  add_index "player_characters", ["in_kingdom"], name: "in_kingdom", using: :btree
  add_index "player_characters", ["in_world"], name: "in_world", using: :btree
  add_index "player_characters", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "player_characters", ["kingdom_level"], name: "kingdom_level", using: :btree
  add_index "player_characters", ["name"], name: "name", using: :btree
  add_index "player_characters", ["player_id"], name: "player_id", using: :btree
  add_index "player_characters", ["race_id"], name: "race_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.string   "handle",                 limit: 32,    default: "",    null: false
    t.string   "passwd",                 limit: 256,   default: "",    null: false
    t.string   "city",                   limit: 32,    default: ""
    t.string   "state",                  limit: 2,     default: ""
    t.string   "country",                limit: 32,    default: ""
    t.string   "email",                  limit: 64,    default: ""
    t.string   "AIM",                    limit: 32,    default: ""
    t.string   "yahoo_sn",               limit: 32,    default: ""
    t.text     "bio",                    limit: 65535
    t.integer  "account_status",         limit: 4,     default: 1,     null: false
    t.boolean  "admin",                                default: false
    t.boolean  "table_editor_access",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
  end

  add_index "players", ["city"], name: "city", using: :btree
  add_index "players", ["confirmation_token"], name: "index_players_on_confirmation_token", unique: true, using: :btree
  add_index "players", ["country"], name: "country", using: :btree
  add_index "players", ["handle"], name: "handle", using: :btree
  add_index "players", ["reset_password_token"], name: "index_players_on_reset_password_token", unique: true, using: :btree
  add_index "players", ["state"], name: "state", using: :btree

  create_table "pref_lists", force: :cascade do |t|
    t.integer  "kingdom_id", limit: 4,  null: false
    t.integer  "thing_id",   limit: 4,  null: false
    t.string   "kind",       limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pref_lists", ["kind"], name: "kind", using: :btree
  add_index "pref_lists", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "pref_lists", ["kingdom_id"], name: "kingdom_id_pref_list_type", using: :btree
  add_index "pref_lists", ["thing_id"], name: "thing_id", using: :btree

  create_table "quest_reqs", force: :cascade do |t|
    t.integer  "quest_id",   limit: 4,                null: false
    t.integer  "quantity",   limit: 4
    t.string   "detail",     limit: 255
    t.string   "kind",       limit: 20,  default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quest_reqs", ["quest_id", "kind"], name: "quest_id_kind", using: :btree
  add_index "quest_reqs", ["quest_id"], name: "quest_id", using: :btree

  create_table "quests", force: :cascade do |t|
    t.string   "name",             limit: 32,  default: "",  null: false
    t.string   "description",      limit: 256
    t.integer  "kingdom_id",       limit: 4,                 null: false
    t.integer  "player_id",        limit: 4,                 null: false
    t.integer  "max_level",        limit: 4,   default: 500
    t.integer  "max_completeable", limit: 4
    t.integer  "quest_status",     limit: 4,                 null: false
    t.integer  "gold",             limit: 4
    t.integer  "item_id",          limit: 4
    t.integer  "quest_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quests", ["id", "quest_status"], name: "id_status", using: :btree
  add_index "quests", ["item_id"], name: "item_id", using: :btree
  add_index "quests", ["kingdom_id", "name"], name: "name", using: :btree
  add_index "quests", ["kingdom_id", "quest_status", "name"], name: "kingdom_id_quest_status_name", using: :btree
  add_index "quests", ["kingdom_id", "quest_status"], name: "kingdom_id_quest_status", using: :btree
  add_index "quests", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "quests", ["player_id"], name: "player_id", using: :btree
  add_index "quests", ["quest_id"], name: "quest_id", using: :btree

  create_table "race_equip_locs", force: :cascade do |t|
    t.integer "race_id",   limit: 4, null: false
    t.integer "equip_loc", limit: 4, null: false
  end

  add_index "race_equip_locs", ["equip_loc"], name: "equip_loc", using: :btree
  add_index "race_equip_locs", ["race_id"], name: "race_id", using: :btree

  create_table "races", force: :cascade do |t|
    t.string   "name",           limit: 32,  default: "",  null: false
    t.string   "description",    limit: 256
    t.integer  "kingdom_id",     limit: 4
    t.integer  "race_body_type", limit: 4,                 null: false
    t.integer  "freepts",        limit: 4,                 null: false
    t.integer  "image_id",       limit: 4,   default: 140
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "races", ["kingdom_id"], name: "kingdom_id", using: :btree
  add_index "races", ["name"], name: "name", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,        default: "", null: false
    t.text     "data",       limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "stats", force: :cascade do |t|
    t.integer  "con",        limit: 4,  default: 0,     null: false
    t.integer  "dam",        limit: 4,  default: 0,     null: false
    t.integer  "dex",        limit: 4,  default: 0,     null: false
    t.integer  "dfn",        limit: 4,  default: 0,     null: false
    t.integer  "int",        limit: 4,  default: 0,     null: false
    t.integer  "mag",        limit: 4,  default: 0,     null: false
    t.integer  "str",        limit: 4,  default: 0,     null: false
    t.integer  "owner_id",   limit: 4,                  null: false
    t.string   "kind",       limit: 20, default: "",    null: false
    t.boolean  "lock",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stats", ["kind", "owner_id"], name: "kind_owner_id", using: :btree

  create_table "system_statuses", force: :cascade do |t|
    t.integer "status", limit: 4
    t.integer "days",   limit: 4
  end

  create_table "table_locks", force: :cascade do |t|
    t.string   "name",       limit: 255, default: "",    null: false
    t.boolean  "locked",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "table_locks", ["name"], name: "index_table_locks_on_name", using: :btree
  add_index "table_locks", ["updated_at"], name: "index_table_locks_on_updated_at", using: :btree

  create_table "trainer_skills", force: :cascade do |t|
    t.float    "max_skill_taught", limit: 24, null: false
    t.integer  "min_sales",        limit: 4,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trainer_skills", ["min_sales"], name: "min_sales", using: :btree

  create_table "world_maps", force: :cascade do |t|
    t.integer  "world_id",   limit: 4,                 null: false
    t.integer  "xpos",       limit: 4,                 null: false
    t.integer  "ypos",       limit: 4,                 null: false
    t.integer  "bigxpos",    limit: 4,                 null: false
    t.integer  "bigypos",    limit: 4,                 null: false
    t.integer  "feature_id", limit: 4
    t.boolean  "lock",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "world_maps", ["feature_id"], name: "feature_id", using: :btree
  add_index "world_maps", ["world_id", "bigxpos", "bigypos", "xpos", "ypos"], name: "world_bixs_bigy_x_y_id", using: :btree
  add_index "world_maps", ["world_id", "bigxpos", "bigypos"], name: "world_id_bigxpos_bigypos", using: :btree
  add_index "world_maps", ["world_id"], name: "world_id", using: :btree

  create_table "worlds", force: :cascade do |t|
    t.string   "name",       limit: 32,   default: "", null: false
    t.integer  "minbigx",    limit: 4,                 null: false
    t.integer  "minbigy",    limit: 4,                 null: false
    t.integer  "maxbigx",    limit: 4,                 null: false
    t.integer  "maxbigy",    limit: 4,                 null: false
    t.integer  "maxx",       limit: 4,                 null: false
    t.integer  "maxy",       limit: 4,                 null: false
    t.string   "text",       limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worlds", ["name"], name: "name", using: :btree

end
