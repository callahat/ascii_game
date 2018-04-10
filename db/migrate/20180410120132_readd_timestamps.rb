class ReaddTimestamps < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up   { change_column :players, :joined, :datetime }
      direction.down { change_column :players, :joined, :date }
    end

    rename_column :players, :joined, :created_at
    add_column :players, :updated_at, :datetime

    add_column :attack_spells, :created_at, :datetime
    add_column :attack_spells, :updated_at, :datetime

    add_column :base_items, :created_at, :datetime
    add_column :base_items, :updated_at, :datetime

    add_column :blacksmith_skills, :created_at, :datetime
    add_column :blacksmith_skills, :updated_at, :datetime

    add_column :c_classes, :created_at, :datetime
    add_column :c_classes, :updated_at, :datetime

    add_column :creatures, :created_at, :datetime
    add_column :creatures, :updated_at, :datetime

    add_column :diseases, :created_at, :datetime
    add_column :diseases, :updated_at, :datetime

    add_column :events, :created_at, :datetime
    add_column :events, :updated_at, :datetime

    add_column :feature_events, :created_at, :datetime
    add_column :feature_events, :updated_at, :datetime

    add_column :features, :created_at, :datetime
    add_column :features, :updated_at, :datetime

    add_column :forum_restrictions, :created_at, :datetime

    add_column :healer_skills, :created_at, :datetime
    add_column :healer_skills, :updated_at, :datetime

    add_column :healing_spells, :created_at, :datetime
    add_column :healing_spells, :updated_at, :datetime

    add_column :healths, :created_at, :datetime
    add_column :healths, :updated_at, :datetime

    add_column :illnesses, :created_at, :datetime
    add_column :illnesses, :updated_at, :datetime

    add_column :images, :created_at, :datetime
    add_column :images, :updated_at, :datetime

    add_column :inventories, :created_at, :datetime
    add_column :inventories, :updated_at, :datetime

    add_column :items, :created_at, :datetime
    add_column :items, :updated_at, :datetime

    add_column :kingdom_bans, :created_at, :datetime

    add_column :kingdom_entries, :created_at, :datetime
    add_column :kingdom_entries, :updated_at, :datetime

    add_column :kingdoms, :created_at, :datetime
    add_column :kingdoms, :updated_at, :datetime

    add_column :level_maps, :created_at, :datetime
    add_column :level_maps, :updated_at, :datetime

    add_column :levels, :created_at, :datetime
    add_column :levels, :updated_at, :datetime

    add_column :log_quest_reqs, :created_at, :datetime
    add_column :log_quest_reqs, :updated_at, :datetime

    add_column :log_quests, :created_at, :datetime
    add_column :log_quests, :updated_at, :datetime

    add_column :name_surfixes, :created_at, :datetime
    add_column :name_surfixes, :updated_at, :datetime

    add_column :name_titles, :created_at, :datetime
    add_column :name_titles, :updated_at, :datetime

    add_column :names, :created_at, :datetime
    add_column :names, :updated_at, :datetime

    add_column :npc_blacksmith_items, :created_at, :datetime
    add_column :npc_blacksmith_items, :updated_at, :datetime

    add_column :npc_merchant_details, :created_at, :datetime
    add_column :npc_merchant_details, :updated_at, :datetime

    add_column :npcs, :created_at, :datetime
    add_column :npcs, :updated_at, :datetime

    add_column :player_characters, :created_at, :datetime
    add_column :player_characters, :updated_at, :datetime

    add_column :pref_lists, :created_at, :datetime
    add_column :pref_lists, :updated_at, :datetime

    add_column :quest_reqs, :created_at, :datetime
    add_column :quest_reqs, :updated_at, :datetime

    add_column :quests, :created_at, :datetime
    add_column :quests, :updated_at, :datetime

    add_column :races, :created_at, :datetime
    add_column :races, :updated_at, :datetime

    add_column :stats, :created_at, :datetime
    add_column :stats, :updated_at, :datetime

    add_column :trainer_skills, :created_at, :datetime
    add_column :trainer_skills, :updated_at, :datetime

    add_column :world_maps, :created_at, :datetime
    add_column :world_maps, :updated_at, :datetime

    add_column :worlds, :created_at, :datetime
    add_column :worlds, :updated_at, :datetime
  end
end
