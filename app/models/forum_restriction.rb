class ForumRestriction < ActiveRecord::Base
  belongs_to :player
  belongs_to :giver, :foreign_key => 'given_by', :class_name => 'Player'

  def self.no_posting(who)
    return self.no_whating('no_posting', who)
  end
  
  def self.no_threding(who)
    return self.no_whating('no_threding', who)
  end
  
  def self.no_viewing(who)
    return self.no_whating('no_viewing', who)
  end
  
  def self.no_whating(what, who)
    return who.forum_restrictions.exists?(
       ['restriction = ? and expires > ?',
        SpecialCode.get_code('restrictions', what),
        Date.today() ] )
  end
  
  def check_expiration(mod, expiry)
    if mod.forum_attribute.mod_level < 9 &&
       (expiry.nil? || expiry == "" || (expiry) > (Date.today + mod.forum_attribute.mod_level*2))
      errors[:expires] << "Too long"
    elsif expiry.nil? || expiry == ""
      self.expires = nil
    else
      self.expires = (expiry < (Date.today + 27.years) ? expiry : (Date.today + 27.years))
    end
  end
  
  def kill_ban(mod)
    if given_by != mod.id && giver.forum_attribute.mod_level > mod.forum_attribute.mod_level
      return false, "Cannot remove a restriction placed by someone with a higher mod level than yourself."
    else
      return destroy, "Removed restriction"
    end
  end

protected
  before_create :check_expiry
  
  def check_expiry
    check_expiration(self.giver, self.expires)
  end
end
