class PrefListFeature < PrefList
	belongs_to :feature, :foreign_key => 'thing_id', :class_name => 'Feature'
	belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Feature'
	
	def self.eligible_list(pid, kid)
		Feature.find(:all,
								:conditions => ['armed and (public or player_id = ? or kingdom_id = ?)', pid, kid],
								:order => 'name')
	end
	
	def self.current_list(k)
		k.pref_list_features
	end
end