require 'test_helper'

class LogQuestTest < ActiveSupport::TestCase
  test "join quest one and abandon" do
    pc = PlayerCharacter.find_by_name("Test PC One")
    q = Quest.find_by_name("Quest One")
    joined, msg = LogQuest.join_quest(pc, q.id)    
    assert joined
    assert pc.log_quests.find_by_quest_id(q.id).reqs.size == 5 #since one is QuestItem and has no log

    #join again, fail
    joined, msg = LogQuest.join_quest(pc, q.id)
    assert !joined
    assert msg == "Already signed up for this quest"
    
    abd, msg = LogQuest.abandon(pc, q.id)
    assert abd
    assert pc.log_quests.find_by_quest_id(q.id).nil?
    abd, msg = LogQuest.abandon(pc, q.id)
    assert !abd
    assert msg == 'Not signed up for the quest submitted for abandonment'
  end
  
  test "incomplete prereqs" do
    pc = PlayerCharacter.find_by_name("Test PC One")
    q = Quest.find_by_name("Quest Two")
    joined, msg = LogQuest.join_quest(pc, q.id)
    assert !joined
    assert msg =~ /Have\snot\scompleted/
end
end
