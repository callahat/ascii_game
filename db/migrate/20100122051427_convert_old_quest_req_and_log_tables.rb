class ConvertOldQuestReqAndLogTables < ActiveRecord::Migration
  def self.up
    #have to add these columns, otherwise the object fails to read the column from the given table,
    #otherwise it doesnt seem to work

    #create a hash to map new req id's to old. Might run out of memory of there are a ton of these, but
    #its simpler/quicker than creating a temporary model just for the sake of using a temporary table
    @old_to_new = {}
    @old_to_new[:quest_creature_kills]={} #key=old id, value=new id in the QuestReq table
    @old_to_new[:quest_explores]      ={}
    @old_to_new[:quest_items]         ={}
    @old_to_new[:quest_kill_n_npcs]   ={}
    @old_to_new[:quest_kill_pcs]      ={}
    @old_to_new[:quest_kill_s_npcs]   ={}
    
    QuestReq.transaction do
      QuestCreatureKill.find_by_sql('select * from quest_creature_kills').each{ |q|
        nq = QuestCreatureKill.create(:quest_id => q.quest_id, :quantity => q.num_kills, :detail => q.creature_id )
        p q.id
        @old_to_new[:quest_creature_kills][q.id] = nq.id
        p "Old:" + q.id.to_s + " New: " + nq.id.to_s
	    p nq }
	  QuestExplore.find_by_sql('select * from quest_explores').each{ |q|
	    nq = QuestExplore.create(:quest_id => q.quest_id, :detail => q.event_id)
        @old_to_new[:quest_explores][q.id] = nq.id
        p nq }
      QuestItem.find_by_sql('select * from quest_items').each{|q|
        nq = QuestItem.create(:quest_id => q.quest_id, :quantity => q.num, :detail => q.item_id )
        @old_to_new[:quest_items][q.id] = nq.id
	    p nq }
	  QuestKillNNpc.find_by_sql('select *, CONCAT(npc_division,":",kingdom_id) as detail from `quest_kill_n_npcs`').each{ |q|
	    nq = QuestKillNNpc.create(:quest_id => q.quest_id, :quantity => q.num_kills, :detail => q.detail ) 
        @old_to_new[:quest_kill_n_npcs][q.id] = nq.id
	    p nq }
	  QuestKillPc.find_by_sql('select * from `quest_kill_pcs`').each{ |q|
	    nq = QuestKillPc.create(:quest_id => q.quest_id, :detail => q.player_character_id ) 
        @old_to_new[:quest_kill_pcs][q.id] = nq.id
	    p nq }
	  QuestKillSNpc.find_by_sql('select * from `quest_kill_s_npcs`').each{ |q|
	    nq = QuestKillSNpc.create(:quest_id => q.quest_id, :detail => q.npc_id ) 
        @old_to_new[:quest_kill_s_npcs][q.id] = nq.id
	    p nq }
    end
    
    p @old_to_new.inspect
    
	LogQuestReq.transaction do
	  LogQuestCreatureKill.find_by_sql('select * from log_quest_creature_kills').each{ |l|
        nq = @old_to_new[:quest_creature_kills][l.quest_creature_kill_id.to_i]
        cid = QuestReq.find(nq).detail
	    p LogQuestCreatureKill.create(:log_quest_id => l.log_quest_id, :owner_id => l.log_quest.player_character_id,
		                            :quest_req_id => nq, :quantity => l.num_kills,
                                    :detail => cid) }
	  LogQuestExplore.find_by_sql('select * from log_quest_explores').each{ |l|
        nq = @old_to_new[:quest_explores][l.quest_explore_id.to_i]
        eid = QuestReq.find(nq).detail
	    p LogQuestExplore.create(:log_quest_id => l.log_quest_id, :owner_id => l.log_quest.player_character_id,
		                       :quest_req_id => nq, :detail => eid) }
	  LogQuestKillNNpc.find_by_sql('select * from log_quest_kill_n_npcs').each{ |l|
        nq = @old_to_new[:quest_kill_n_npcs][l.quest_kill_n_npc_id.to_i]
        qrd = QuestReq.find(nq).detail
	    p LogQuestKillNNpc.create(:log_quest_id => l.log_quest_id, :owner_id => l.log_quest.player_character_id,
		                        :quest_req_id => nq, :quantity => l.num_kills,
                                :detail => qrd ) }
	  LogQuestKillPc.find_by_sql('select * from log_quest_kill_pcs').each{ |l|
        nq = @old_to_new[:quest_kill_pcs][l.quest_kill_pc_id.to_i]
        pcid = QuestReq.find(nq).detail
	    p LogQuestKillPc.create(:log_quest_id => l.log_quest_id, :owner_id => l.log_quest.player_character_id,
		                      :quest_req_id => nq, :detail => pcid) }
	  LogQuestKillSNpc.find_by_sql('select * from log_quest_kill_s_npcs').each{ |l|
        nq = @old_to_new[:quest_kill_s_npcs][l.quest_kill_s_npc_id.to_i]
        npcid = QuestReq.find(nq).detail
	    p LogQuestKillSNpc.create(:log_quest_id => l.log_quest_id, :owner_id => l.log_quest.player_character_id,
		                        :quest_req_id => nq, :detail => npcid) }
	end
    
    @old_to_new = nil
  end

  def self.down
    LogQuestReq.delete_all
    QuestReq.destroy_all
  end
end
