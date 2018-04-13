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
         :validatable,
         :confirmable

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

  # Authenticate a player.
  # /borrrowed code
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(name, pass)
    #print sha1(pass).inspect
    find_by(["handle = ? AND passwd = ?", name, sha1(pass)])
  end
  
  def self.authenticate?(handle, pass)
    player = self.authenticate(handle, pass)
    return false if player.nil?
    return true if player.handle == handle
    
    return false
  end

  #Pagination related stuff
  def self.get_page(page)
    order('handle') \
      .paginate(:per_page => 25, :page => page)
  end
  
protected

  def self.sha1(pass)
    Digest::SHA1.hexdigest("45354bcd4--#{pass}--de4dbe3f")
  end

  before_create :cryptpass

  def cryptpass
    write_attribute "passwd", self.class.sha1(passwd)
  end
  
  before_update :cryptpass_not_null, :preserve_status
  
  def cryptpass_not_null
    player = self.class.find(self.id)
    #if passwd is empty, or if passwd matches what's already onfile, don't rehash.
    #this saves the password when the player row is updated from releasing the lock
    if passwd.empty? || passwd == player.passwd
      self.passwd = player.passwd
    else
      write_attribute "passwd", self.class.sha1(passwd)
    end
  end
  
  #prevent an attack to give a player certain abilities
  def preserve_status
    player = self.class.find(self.id)
    self.account_status = player.account_status
    self.handle = player.handle
    #These really should be moved into a different table, but for now should be ok.
    self.admin = player.admin
    self.table_editor_access = player.table_editor_access
    return true #otherwise, if player does not have table editor access, this returns FALSE and prevents update
  end


  # validates_uniqueness_of :handle, :on => :create
  # validates_presence_of :handle,:passwd, :on => :create
  # validates_presence_of :email

  after_create :make_forum_attribute
  
  def make_forum_attribute
    ForumUserAttribute.create(:user_id => self.id, :posts => 0, :mod_level => 0)
  end

end
