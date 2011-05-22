class ForumNodeThread < ForumNode
  has_many :forum_node_posts, :foreign_key => :forum_node_id
  alias :posts :forum_node_posts
  
  alias :board :parent
  alias :forum_node_board :parent
  
  class CanMakeThreadValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless record.can_be_made_by( Player.find(record[attribute]) )
        record.errors[attribute] << "Cannot create thread"
      end
    end
  end
  
  validates :player_id, :can_make_thread => true, :on => :create
  
  validates_presence_of :name
  
  default_scope :order => 'updated_at ASC'
  
  def can_be_made_by(user)
    return false unless user
    return false if user.player_characters.find(:first, :conditions => 'level > 9').nil?
    user.forum_attribute.mod_level == 9 ||
      !(ForumRestriction.no_threding(user) ||
        parent_forum_node(:is_deleted) ||
        parent_forum_node(:is_hidden) ||
        parent_forum_node(:is_locked) ||
        (parent_forum_node(:is_mods_only) && user.forum_attribute.mod_level < 1) )
  end
end
