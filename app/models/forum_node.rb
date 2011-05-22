class ForumNode < ActiveRecord::Base
  self.inheritance_column = 'kind'

  belongs_to :last_post, :foreign_key => 'last_post_id', :class_name => 'ForumNode'
  belongs_to :parent, :foreign_key => :forum_node_id, :class_name => 'ForumNode'
  belongs_to :player
  belongs_to :forum_node

  has_many :childs, :foreign_key => 'forum_node_id', :class_name => 'ForumNode'

  validates_uniqueness_of :name, :scope => [ :forum_node_id ], :allow_blank => true
  
  attr_accessible :name, :text
  
  def time_of_last_posted_child
    if (@thred = last_posted_child) && @thred.childs.size > 0
      return @thred.childs.last.created_at.strftime("%m-%d-%Y %I:%M.%S %p")
    else
      return nil
    end
  end

  def parent_forum_node(status) #is recursion even allowed? yes, at least it looks like it is.
    if self.parent.nil? 
      return self[status]
    elsif self[status]
      return true
    else
      return self[status] || self.forum_node.parent_forum_node(status)
    end
  end
  
  def can_be_edited_by(user)
    user && (user.forum_attribute.mod_level == 9)
  end
  
  def can_be_deleted_by(user)
    user && (user.forum_attribute.mod_level == 9)
  end
  
  def can_be_made_by(user)
    user && user.forum_attribute.mod_level == 9
  end
  
  def can_be_viewed_by(user)
    if user
      user.forum_attribute.mod_level >= 7 ||
      !(ForumRestriction.no_viewing(user) ||
        parent_forum_node(:is_deleted) ||
        (parent_forum_node(:is_hidden) && user.forum_attribute.mod_level < 5) ||
        (parent_forum_node(:is_mods_only) && user.forum_attribute.mod_level < 1))
    else
      !(parent_forum_node(:is_deleted) ||
        parent_forum_node(:is_hidden) ||
        parent_forum_node(:is_mods_only) )
    end
  end
  
  #Pagination related stuff
  def self.get_page(page, flags, bid = nil)
    where( bid.nil? ? ['forum_node_id is NULL' + flags.to_s] : ['forum_node_id = ?' + flags.to_s, bid] ) \
      .order('"created_at DESC"') \
      .paginate(:per_page => 15, :page => page)
  end

protected
  before_create :set_elders 
  
  def set_elders
    write_attribute "elders", (forum_node ? forum_node.elders + 1 : 0)
  end
end
