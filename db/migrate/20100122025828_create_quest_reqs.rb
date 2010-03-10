class CreateQuestReqs < ActiveRecord::Migration
  def self.up
    create_table :quest_reqs do |t|
	  t.integer "quest_id",                                   :null => false
	  t.integer "quantity"
      t.string  "detail"
	  t.string  "kind",        :limit => 20,  :default => "", :null => false
    end
    add_index "quest_reqs", ["quest_id"], :name => "quest_id"
    add_index "quest_reqs", ["quest_id", "kind"], :name => "quest_id_kind"
  end

  def self.down
    drop_table :quest_reqs
  end
end
