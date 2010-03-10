class Kingdom < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :world

	has_one :kingdom_entry

	has_many :races
	has_many :creatures, :order => 'name'
	has_many :events
	has_many :features, :conditions => ['armed = true']
	has_many :all_features, :foreign_key => "kingdom_id", :class_name => "Feature"
	has_many :images, :order => 'name'
	has_many :kingdom_bans
	has_many :kingdom_items
	has_many :levels, :order => 'level'
	has_many :npcs, :order => 'name'
	has_many :guards, :class_name => 'Npc', :include => :health,
										:conditions => ['is_hired = true AND npc_division = ? and healths.wellness != ?',
										SpecialCode.get_code('npc_division','guard'), SpecialCode.get_code('wellness','dead')]
	has_many :live_npcs, :class_name => 'Npc', :include => :health,
											 :conditions => ['healths.wellness != ?', SpecialCode.get_code('wellness','dead')], :order => 'name'
	has_many :pandemics, :foreign_key => 'owner_id'
	has_many :illnesses, :foreign_key => 'owner_id', :class_name => 'Pandemic'
	has_many :player_characters
	has_many :quests, :order => '\'quest_status\',\'name\''
	has_many :quest_kill_n_npcs
	has_many :kingdom_empty_shops
	has_many :kingdom_notices, :order => '"datetime DESC"'
	
	has_many :creature_pref_list, :include => 'creature', :conditions => ['pref_list_type = ?', SpecialCode.get_code('pref_list_type','creatures')], :order => 'creatures.public,creatures.name', :class_name => 'PrefList'
	has_many :event_pref_list, :include => 'event', :conditions => ['pref_list_type = ?', SpecialCode.get_code('pref_list_type','events')], :order => 'events.name', :class_name => 'PrefList'
	has_many :feature_pref_list, :include => 'feature', :conditions => ['pref_list_type = ?', SpecialCode.get_code('pref_list_type','features')], :order => 'features.public,features.name', :class_name => 'PrefList'
	
	has_many :pref_lists
	
	validates_uniqueness_of :name
	
	
	def self.pay_tax(tax, kingdom_id)
		Kingdom.transaction do
			@kingdom = self.find(kingdom_id, :lock => true)
			@kingdom.gold += tax
		@kingdom.save!
		end
	end
	
	#returns the number reserved
	def reserve_peasants(peasants)
		@peasants = ( self.num_peasants > peasants ? peasants : self.num_peasants )
		Kingdom.transaction do
			self.lock!
			self.num_peasants -= @peasants
			self.save!
end
		@peasants
	end
	
	#change the king
	def change_king(pcid)
		Kingdom.transaction do
			self.lock!
			self.player_character = pcid
			self.save!
		end
	end
end
