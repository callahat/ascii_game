class ForumNodeBoard < ForumNode
  has_many :forum_node_threads, :foreign_key => :forum_node_id
  alias :threads :forum_node_threads
  
  class CanMakeBoardValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless record.can_be_made_by( Player.find(record[attribute]) )
        record.errors[attribute] << "Cannot create board"
      end
    end
  end
  
  validates :player_id, :can_make_board => true, :on => :create
  
  def parent
    nil
  end
  

  validates_presence_of :name
  
  default_scope { order('name ASC') }
  
  def can_be_made_by(user)
    user && user.forum_attribute.mod_level == 9
  end
end
