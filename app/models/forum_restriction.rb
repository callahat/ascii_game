class ForumRestriction < ActiveRecord::Base
	belongs_to :player
	belongs_to :giver, :foreign_key => 'given_by', :class_name => 'Player'
	
	def self.no_posting(who)
		p who.player_characters.find(:first, :conditions => 'level > 9')
		return(true) if who.player_characters.find(:first, :conditions => 'level > 9').nil?
		return self.no_whating('no_posting', who)
	end
	
	def self.no_threding(who)
		p who.player_characters.find(:first, :conditions => 'level > 9')
		return(true) if who.player_characters.find(:first, :conditions => 'level > 9').nil?
		return self.no_whating('no_threding', who)
	end
	
	def self.no_viewing(who)
		return self.no_whating('no_viewing', who)
	end
	
	def self.no_whating(what, who)
		return who.forum_restrictions.exists?(:restriction => SpecialCode.get_code('restrictions', what))
	end
end
