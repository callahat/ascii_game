class CreateLogQuestReqs < ActiveRecord::Migration
  def self.up
    create_table :log_quest_reqs do |t|
	  t.integer "log_quest_id",                               :null => false
      t.integer "owner_id",                                   :null => false
      t.integer "quest_req_id",                               :null => false
	  t.integer "quantity",                   :default => 1
      t.string  "detail"
	  t.string  "kind",        :limit => 20,  :default => "", :null => false
    end
	add_index "log_quest_reqs", ["log_quest_id"], :name => "log_quest_id"
	add_index "log_quest_reqs", ["owner_id"], :name => "owner_id"
	add_index "log_quest_reqs", ["quest_req_id"], :name => "quest_req_id"
	add_index "log_quest_reqs", ["kind","owner_id"], :name => "kind_owner_id"
	add_index "log_quest_reqs", ["kind","owner_id","quest_req_id"], :name => "kind_owner_id_quest_req_id"
	add_index "log_quest_reqs", ["kind","owner_id","log_quest_id"], :name => "kind_owner_id_log_quest_id"
  end

  def self.down
    drop_table :log_quest_reqs
  end
end
