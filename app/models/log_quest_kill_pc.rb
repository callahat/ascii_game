class LogQuestKillPc < LogQuestReq
	belongs_to :quest_req, :foreign_key => 'quest_req_id', :class_name => 'QuestKillPc'
	belongs_to :player_character, :foreign_key => 'detail'
	
	def self.complete_req(pcid,kill_pcid)
		@lq = LogQuestKillPc.find(:all, :conditions => ['owner_id = ? AND detail = ?', pcid, kill_pcid])
		
		for lq in @lq
			lq.destroy
		end
	end
	
	def to_sentence
		pc = self.player_character
		"Kill " + pc.name + " of " + Kingdom.find(pc.kingdom_id).name + "."
	end
end
