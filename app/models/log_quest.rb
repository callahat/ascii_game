class LogQuest < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :quest
	
	has_many :reqs, :class_name => "LogQuestReq"
	
	has_many :creature_kills, :class_name => "LogQuestCreatureKill"
	has_many :explores, :class_name => "LogQuestExplore"
	has_many :kill_n_npcs, :class_name => "LogQuestKillNNpc"
	has_many :kill_pcs, :class_name => "LogQuestKillPc"
	has_many :kill_s_npcs, :class_name => "LogQuestKillSNpc"
			
	
	#returns true if successfully joined & created the logs, otherwise retuns false and
	#possibly a message
	def self.join_quest(pc, qid)
		@quest = Quest.find(:first,
						:conditions => ['id = ? AND kingdom_id = ? AND quest_status = ?',
						qid, pc[:in_kingdom], SpecialCode.get_code('quest_status','active') ])
		
		if @quest.nil?
			return false, "Could not find that quest"
		elsif pc.log_quests.find(:first, :conditions => ['quest_id = ?', @quest.id])
			return false, "Already signed up for this quest"
		elsif DoneQuest.find(:first, :conditions => ['quest_id = ? and player_character_id = ?', qid, pc[:id] ])
			return false, "Already completed this quest"
		elsif @quest.max_level && @quest.max_level < pc[:level]
			return false, "Player Character's level is too high to join this quest"
		elsif @quest.quest_id &&
				DoneQuest.find(:first,:conditions => ['quest_id = ? and player_character_id = ?', @quest.quest_id, pc[:id] ]).nil?
			return false, "Have not completed " + @quest.quest.name + ", a prerequisite for this quest"
			end
			
		new_log = create(:player_character_id => pc[:id], :quest_id => qid)
		return false, "Failed to create the log for some reason" unless new_log
	
		#create the requirement logs
		for req in @quest.reqs
			next if req.kind == "QuestItem"
			print "Failed to create requirement!" unless
			Rails.module_eval("Log"+req.class.to_s).create(
																								:log_quest_id => new_log.id,
																								:owner_id => pc[:id],
																								:quest_req_id => req.id,
																								:quantity => req[:quantity],
																								:detail => req.detail )
			end
		true
		end
	
	def self.abandon(pc, qid)
		log_quest = pc.log_quests.find(:first, :conditions => ['quest_id = ?', qid])
		
		if log_quest.nil?
			return false, 'Not signed up for the quest submitted for abandonment'
		elsif log_quest.quest.done_quests.find(:first, :conditions => ['player_character_id = ?', pc[:id]])
			return false, 'Can\'t abandon a quest already completed'
	end
	
	log_quest.reqs.each{|lqr| lqr.destroy}
		log_quest.destroy
	end
	
	def all_logs
		return self.reqs 
	end
end