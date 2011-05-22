class ForumNodePost < ForumNode
  #Tree structure much more complex to implement for a forum (with pagination)
  #Stick with one level of posts to a thread.
  #has_many :forum_node_posts, :foreign_key => :forum_node_id
  #alias :replies :forum_node_posts
  
  validates_presence_of :text
  
  default_scope :order => 'created_at ASC'
  
  class CanMakePostValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless record.can_be_made_by( Player.find(record[attribute]) )
        record.errors[attribute] << "Cannot create post"
      end
    end
  end
  
  validates :player_id, :can_make_post => true, :on => :create
  
  def thread
    #Assumes posts cannot be directly attached to boards, but can be to other posts
    return parent if parent.class == ForumNodeThread
    parent.thread
  end
  
  def board
    thread.forum_node_board
  end
  
  def mark_deleted(user)
    if player_id != user.id && user.forum_attribute.mod_level < 8
      if user.forum_attribute.mod_level < 1
        return "You cannot delete a post that is not yours"
      else
        return "You may not edit delete a post; your mod level is insufficient"
      end
    else
      is_deleted = true
      edit_notices = edit_notices.to_s + '<br/>Deleted by ' + user.handle + ' at ' + Time.now.strftime("%m-%d-%Y %I:%M.%S %p")
      save
      return "Post deleted"
    end
  end
  
  def update_post(user, text, mods_only)
    self.text = text
    self.edit_notices = edit_notices.to_s + '<br/>Edited by ' + user + ' at ' + Time.now.strftime("%m-%d-%Y %I:%M.%S %p")
    self.is_mods_only = mods_only
    self.save!
  end
  
  def can_be_edited_by(user)
    user &&
      (self.player_id == user.id || self.player.forum_attribute.mod_level < user.forum_attribute.mod_level) &&
      !ForumRestriction.no_posting(user)
  end
  
  def can_be_deleted_by(user)
    user && (self.player_id == user.id || (user.forum_attribute.mod_level > 7))
  end
  
  def can_be_made_by(user)
    return false unless user
    return false if user.player_characters.find(:first, :conditions => 'level > 9').nil?
    user.forum_attribute.mod_level == 9 ||
      !(ForumRestriction.no_posting(user) ||
        parent_forum_node(:is_deleted) ||
        parent_forum_node(:is_hidden) ||
        parent_forum_node(:is_locked) ||
        (parent_forum_node(:is_mods_only) && user.forum_attribute.mod_level < 1) )
  end
  
protected
  after_create :touch_parents

  def touch_parents
    pa = self.parent
    while pa
      pa.transaction do
        pa.lock!
        pa.post_count += 1
        pa.last_post_id = self.id if pa.elders < 2
        pa.save!
      end
      pa = pa.parent
    end
  end
end
