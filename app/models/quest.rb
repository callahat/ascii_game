class Quest < ActiveRecord::Base
	belongs_to :item
	belongs_to :kingdom
	belongs_to :player
	belongs_to :quest

	has_many :quests
	has_many :done_quests
	has_many :log_quests
	
	has_many :reqs, :class_name => "QuestReq"
	
	has_many :creature_kills, :class_name => "QuestCreatureKill"
	has_many :explores, :class_name => "QuestExplore"
	has_many :items, :class_name => "QuestItem"
	has_many :kill_n_npcs, :class_name => "QuestKillNNpc"
	has_many :kill_pcs, :class_name => "QuestKillPc"
	has_many :kill_s_npcs, :class_name => "QuestKillSNpc"
	
	validates_presence_of :name,:kingdom_id,:player_id,:quest_status
	validates_uniqueness_of :name
	
	def validate
		if !max_level.nil?
			if max_level < 0 || max_level > 500
				errors.add("max_level","must be betwen 0 and 500.")
			end
		end
		if !max_completeable.nil?
			if max_completeable < 0
				errors.add("max_completeable","must be greater than 0.")
			end
		end
	end
	
	def all_reqs
		return self.reqs
	end
	
	#Pagination related stuff
	def self.per_page
		15
	end
	
	def self.get_page(page, kid = nil)
		if kid.nil?
		paginate(:page => page, :order => 'quest_status,name' )
		else
			paginate(:page => page, :conditions => ['kingdom_id = ?', kid], :order => 'quest_status,name' )
		end
	end
end
