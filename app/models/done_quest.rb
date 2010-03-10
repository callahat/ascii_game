class DoneQuest < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :quest
	
	#Pagination related stuff
	def self.per_page
		20
	end
	
	def self.get_page(page, pcid = nil)
		parms = {:page => page,
					 :joins => 'INNER JOIN quests on done_quests.quest_id = quests.id',
					 :order => '"done_quests.date DESC","quests.name"'}
	parms.merge!(:conditions => ['player_character_id = ?', pcid]) unless pcid.nil?
	
		paginate(parms)
	end
end
