class KingdomNotice < ActiveRecord::Base
	belongs_to :kingdom
	
	validates_presence_of :text,:shown_to
	
	def self.create_storm_gate_notice(name, kid)
		#create kingdom notice of a player storming the gate
		create(	:kingdom_id => kid,
						:shown_to => SpecialCode.get_code('shown_to','king'),
						:text => name + " stormed the gates and gained entry to the kingdom.",
						:signed => "Captain of the Guard")
	end
	
	def self.create_coup_notice(name, kid)
		create(	:kingdom_id => kid,
						:shown_to => SpecialCode.get_code('shown_to','everyone'),
						:text => "The former king has been violently overthrown by " + name + " who has assumed the crown",
						:signed => "Minister of the Interior")
	end
	
	#Pagination related stuff
	def self.per_page
		20
	end
	
	def self.get_page(page, kid = nil)
		if kid.nil?
		paginate(:page => page, :order => '"datetime DESC"' )
	else
			paginate(:page => page, :conditions => ['kingdom_id = ?', kid], :order => '"datetime DESC"' )
	end
	end
end
