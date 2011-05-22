class ForumUserAttribute < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'Player'
  alias :player :user
end
