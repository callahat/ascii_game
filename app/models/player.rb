#require 'digest/sha1'

class Player < ActiveRecord::Base
  include UserAuthentication

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable
         # :confirmable

  has_many :forum_node_boards
  has_many :creatures
  has_many :events
  has_many :features
  has_many :images
  has_many :forum_node_posts
  has_many :quests
  has_many :forum_node_threads
  has_many :player_characters, ->{ order(:name) }
  has_many :forum_restrictions, ->{ where(['expires is null OR expires > ?', Time.now.to_date]) }
  
  has_one :forum_user_attribute, :foreign_key => 'user_id'
  alias :forum_attribute :forum_user_attribute


  validates :handle,
            :presence => true,
            :uniqueness => {
                :case_sensitive => false
            }

  #Pagination related stuff
  def self.get_page(page)
    order('handle') \
      .paginate(:per_page => 25, :page => page)
  end
  
protected

  # TODO: Remove after a while, when its likely that no old players haven't signed in to convert their password
  def self.sha1(pass)
    Digest::SHA1.hexdigest("45354bcd4--#{pass}--de4dbe3f")
  end

  after_create :make_forum_attribute
  
  def make_forum_attribute
    ForumUserAttribute.create(:user_id => self.id, :posts => 0, :mod_level => 0)
  end

end
