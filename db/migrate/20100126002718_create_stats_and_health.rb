class CreateStatsAndHealth < ActiveRecord::Migration
  def self.up
    self.create_the_tables
    self.add_new_columns
    
    self.copy_to_stats_table
    self.copy_to_healths_table
    
    self.cleanup
  end

  def self.down
    raise IrreversibleMigration
    #Too much work and not worth making this able to be rolled back
  end
  
  #helper functions
protected
  def self.create_the_tables
    #create new tables
    create_table :stats do |t|
      t.integer "con",                    :default => 0, :null => false
      t.integer "dam",                    :default => 0, :null => false
      t.integer "dex",                    :default => 0, :null => false
      t.integer "dfn",                    :default => 0, :null => false
      t.integer "int",                    :default => 0, :null => false
      t.integer "mag",                    :default => 0, :null => false
      t.integer "str",                    :default => 0, :null => false
      t.integer "owner_id",                              :null => false
      t.string  "kind",    :limit => 20,  :default => "", :null => false
      t.boolean "lock",                   :default => false
    end
    add_index "stats", ["kind", "owner_id"], :name => "kind_owner_id"

    
    create_table :healths do |t|
      t.integer "HP",                     :default => 0, :null => false
      t.integer "MP",                     :default => 0, :null => false
      t.integer "base_HP",                :default => 0, :null => false
      t.integer "base_MP",                :default => 0, :null => false
      t.integer "wellness",               :default => 0, :null => false
      t.integer "owner_id",                              :null => false
      t.string  "kind",    :limit => 20,  :default => "", :null => false
      t.boolean "lock",                   :default => false
    end
    add_index "healths", ["kind", "owner_id"], :name => "kind_owner_id"
  end
  
  def self.add_new_columns
    rename_column :base_items, :dfn_mod, :dfn
    rename_column :base_items, :dam_mod, :dam
    
    rename_column :player_characters, :max_HP, :base_HP
    rename_column :player_characters, :max_MP, :base_MP
    
    add_column :c_classes,         :freepts,      :integer, :null => false
    add_column :races,             :freepts,      :integer, :null => false
  end
  
  def self.copy_to_stats_table
    #copy the stats from the other rows to the stat table
    [BaseItem, Creature, Disease, EventStat, Item, Npc].each{|table|
      table.all.each{|b|
        Rails.module_eval('Stat' + table.to_s).create(Stat.to_symbols_hash(b).merge(:owner_id => b.id) ) } }
    #CClass, Race, and PlayerCharacter are exceptions to the above
    CClass.all.each{|cc|
      StatCClass.create( Stat.to_symbols_hash(cc.c_class_levels.find_by_level(0)).merge(:owner_id => cc.id) )
      cc.update_attributes(:freepts => cc.c_class_levels.find_by_level(0)[:freepts]) }
    Race.all.each{|r|
      StatRace.create( Stat.to_symbols_hash(r.race_levels.find_by_level(0)).merge(:owner_id => r.id) )
      r.update_attributes(:freepts => r.race_levels.find_by_level(0)[:freepts]) }
    PlayerCharacter.all.each{|pc|
      comb = pc.race.level_zero.add_stats(pc.c_class.level_zero)
      StatPcLevelZero.create(Stat.to_symbols_hash(comb).merge(:owner_id => pc.id))
      ["", "base_", "trn_"].each{|sym|
        h = {:owner_id => pc.id}
        Stat.symbols.each{|a| h[a] = pc[(sym+a.to_s).to_sym]}
        StatPc.create(h) if sym == ""
        StatPcTrn.create(h) if sym == "trn_"
        StatPcBase.create(h) if sym == "base_" } }
  end
  
  def self.copy_to_healths_table
    PlayerCharacter.all.each{|pc|
        HealthPc.create( Health.to_symbols_hash(pc).merge(:owner_id => pc.id) ) }
    Npc.all.each{|npc|
        HealthNpc.create( Health.to_symbols_hash(npc).merge(:owner_id => npc.id) ) }
    EventStat.all.each{|es|
        HealthEventStat.create( Health.to_symbols_hash(es).merge(:owner_id => es.id) ) }
  end
  
  def self.cleanup
    #remove embeded stat columns from tables
    remove_column :base_items,        :dfn
    remove_column :base_items,        :dam
    
    remove_column :npcs,              :HP
    remove_column :npcs,              :base_HP
    remove_column :npcs,              :wellness
    
    remove_column :player_characters, :HP
    remove_column :player_characters, :MP
    remove_column :player_characters, :base_HP
    remove_column :player_characters, :base_MP
    remove_column :player_characters, :wellness
    
    remove_column :event_stats,       :HP
    remove_column :event_stats,       :MP
    
    ["", "base_", "trn_"].each{|sym| Stat.symbols.each{|a| 
      remove_column :player_characters, (sym + a.to_s).to_sym } }
    [:creatures, :diseases, :event_stats, :items, :npcs].each{|table| Stat.symbols.each{|a| 
      remove_column table, a rescue print "*\"" +a.to_s + "\" not a column in " + table.to_s + "\n" } }
    drop_table :c_class_levels
    drop_table :race_levels
  end
end