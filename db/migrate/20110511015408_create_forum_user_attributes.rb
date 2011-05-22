class CreateForumUserAttributes < ActiveRecord::Migration
  def self.up
    create_table :forum_user_attributes do |t|
      t.integer :user_id
      t.integer :mod_level
      t.integer :posts
      t.boolean :lock

      t.timestamps
    end

    change_table :forum_user_attributes do |t|
      t.index   :user_id
      t.index   :posts    
    end

    Player.all.each do |p|
      ForumUserAttribute.create(:user_id => p.id, :mod_level => p.mod_level, :posts => p.forum_node_posts.size)
    end
    
    add_column :forum_nodes, :post_count, :integer, :default => 0
    add_column :forum_nodes, :last_post_id, :integer
    
    remove_column :players, :mod_level
    
    #ForumNodePost.all.each do |fn|
    #  visible_posts = fn.childs.find(:all, :conditions => { :is_hidden => false, :is_deleted => false, :is_mods_only => false } )
    #  fn.post_count = visible_posts.size
    #  fn.last_post_id = visible_posts.last.id if visible_posts.last
    #  fn.save
    #end
    p "Updating thread post counts"
    ForumNodeThread.all.each do |fn|
      visible_posts = fn.posts.find(:all, :conditions => { :is_hidden => false, :is_deleted => false, :is_mods_only => false } )
      fn.post_count = visible_posts.size
      p fn.last_post_id = visible_posts.last.id if visible_posts.last
      p fn.save
    end
    p "Updating board thred counts"
    ForumNodeBoard.all.each do |fn|
      visible_threds = fn.threads.find(:all, :conditions => { :is_hidden => false, :is_deleted => false, :is_mods_only => false } )
      fn.post_count = visible_threds.size
      if visible_threds.size > 0
        threds = visible_threds.inject(visible_threds.first){|h,m| h = (h.updated_at >= m.updated_at ? h : m )  } 
        fn.last_post_id = threds
        p fn.last_post_id
      end
      p fn.save
    end
  end

  def self.down
    add_column :players, :mod_level, :integer
    
    ForumUserAttribute.all.each do |f|
      f.user.update_attribute(:mod_level, f.mod_level)
    end
    
    remove_column :forum_nodes, :post_count
    remove_column :forum_nodes, :last_post_id
  
    drop_table :forum_user_attributes
  end
end
