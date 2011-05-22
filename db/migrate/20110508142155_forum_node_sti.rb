class ForumNodeSti < ActiveRecord::Migration
  def self.up
    rename_column :forum_nodes, :datetime, :created_at
    change_table :forum_nodes do |t|
      t.datetime :updated_at
      
      t.string :kind, :limit => 20
      t.boolean :lock
    
      t.remove_index :name => "forum_node_id"
      t.remove_index :name => "name"
      t.remove_index :name => "datetime"
      t.remove_index :name => "forum_node_id_is_locked"
      t.remove_index :name => "forum_node_id_is_hidden"
      t.remove_index :name => "forum_node_id_is_deleted"
      t.remove_index :name => "forum_node_id_is_mods_only"
        
      t.index   :kind
      t.index   [:kind, :forum_node_id], :name => "kind_forum_node_id"
      t.index   [:kind, :forum_node_id, :is_locked], :name => "kind_forum_node_id_is_locked"
      t.index   [:kind, :forum_node_id, :is_hidden], :name => "kind_forum_node_id_is_hidden"
      t.index   [:kind, :forum_node_id, :is_deleted], :name => "kind_forum_node_id_is_deleted"
      t.index   [:kind, :forum_node_id, :is_mods_only], :name => "kind_forum_node_id_is_mods_only"

      ForumNode.all.each{|node|
        if node.forum_node == nil
          node.update_attribute(:kind, "ForumNodeBoard")
        elsif node.forum_node.forum_node == nil
          node.update_attribute(:kind, "ForumNodeThread")
        else #Not a board, not a thread, must be a post
          node.update_attribute(:kind, "ForumNodePost")
        end
      }
    end
  end

  def self.down
    rename_column :forum_nodes, :created_at, :datetime
    change_table :forum_nodes do |t|
      t.index :forum_node_id, :name => :forum_node_id
      t.index :name, :name => :name
      t.index :datetime, :name => :datetime
      t.index [:forum_node_id, :is_locked], :name => :forum_node_id_is_locked
      t.index [:forum_node_id, :is_hidden], :name => :forum_node_id_is_hidden
      t.index [:forum_node_id, :is_deleted], :name => :forum_node_id_is_deleted
      t.index [:forum_node_id, :is_mods_only], :name => :forum_node_id_is_mods_only
        
      t.remove_index :kind
      t.remove_index :name => :kind_forum_node_id
      t.remove_index :name => :kind_forum_node_id_is_locked
      t.remove_index :name => :kind_forum_node_id_is_hidden
      t.remove_index :name => :kind_forum_node_id_is_deleted
      t.remove_index :name => :kind_forum_node_id_is_mods_only
      
      t.remove :kind
      t.remove :updated_at
      t.remove :lock
    end
  end
end
