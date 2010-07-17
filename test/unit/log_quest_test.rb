require 'test_helper'

class LogQuestTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@quest1 = Quest.find_by_name("Quest One")
		@quest2 = Quest.find_by_name("Quest Two")
	end

	test "join quest one and abandon" do
		joined, msg = LogQuest.join_quest(@pc, @quest1.id)
		assert joined
		assert @pc.log_quests.find_by_quest_id(@quest1.id).reqs.size == 6 #since one is QuestItem and has no log

		#join again, fail
		joined, msg = LogQuest.join_quest(@pc, @quest1.id)
		assert !joined
		assert msg == "Already signed up for this quest"
		
		abd, msg = LogQuest.abandon(@pc, @quest1.id)
		assert abd
		assert @pc.log_quests.find_by_quest_id(@quest1.id).nil?
		abd, msg = LogQuest.abandon(@pc, @quest1.id)
		assert !abd
		assert msg == 'Not signed up for the quest submitted for abandonment'
	end
	
	test "incomplete prereqs" do
		joined, msg = LogQuest.join_quest(@pc, @quest2.id)
		assert !joined
		assert msg =~ /Have\snot\scompleted/
	end
	
	test "reqs met" do
		joined, msg = LogQuest.join_quest(@pc, @quest1.id)
		@quest_log = @pc.log_quests.find_by_quest_id(@quest1.id)
		assert !@quest_log.reqs_met
		@quest_log.reqs.destroy_all
		assert @quest_log.reqs_met
	end
	
	test "complete quest" do
		joined, msg = LogQuest.join_quest(@pc, @quest1.id)
		assert joined
		assert @pc.done_quests.find(:first, :conditions => ['quest_id = ?', @quest1.id]).nil?
		
		@quest_log = @pc.log_quests.find_by_quest_id(@quest1.id)
		assert @quest_log.reqs.size == 6 #since one is QuestItem and has no log
		assert !@quest_log.complete_quest
		
		@quest_log.reqs.destroy_all
		
		@quest_log.quest.update_attribute(:quest_status, SpecialCode.get_code('quest_status','all completed'))
		assert !@quest_log.complete_quest
		
		@quest_log.quest.update_attribute(:quest_status, SpecialCode.get_code('quest_status','active'))
		assert @quest_log.complete_quest
		assert @pc.done_quests.find(:first, :conditions => ['quest_id = ?', @quest1.id])
	end
	
	test "collect reward using kingdom gold" do
		joined, msg = LogQuest.join_quest(@pc, @quest1.id)
		assert joined
		@quest_log = @pc.log_quests.find_by_quest_id(@quest1.id)
		res, msg = @quest_log.collect_reward
		assert !res
		assert msg =~ /Cannot collect/
		@quest_log.reqs.destroy_all
		@quest_log.complete_quest
		
		@quest_log.quest.kingdom.update_attribute(:gold, 0)
		res, msg = @quest_log.collect_reward
		assert !res
		assert msg =~ /Not enough gold/, msg
		
		@quest_log.quest.kingdom.update_attribute(:gold, 500)
		
		@quest_log.quest.update_attribute(:item_id, 99)
		res, msg = @quest_log.collect_reward
		assert !res
		assert msg =~ /Insufficient resources/, msg
		
		@quest_log.quest.kingdom.update_attribute(:gold, 1000000)
		
		assert @pc.items.find(:first, :conditions => ['item_id = ?', 99]).nil?
		assert_difference '@quest_log.quest.kingdom.gold', -(500+99*50) do
			assert_difference '@pc.gold', +500 do
				res, msg = @quest_log.collect_reward
				assert res
				@pc.reload
				@pc.items.reload
			end
		end
		assert @pc.items.find(:first, :conditions => ['item_id = ?', 99])
		assert @pc.items.find(:first, :conditions => ['item_id = ?', 99]).quantity == 1
	end
	
	test "collect reward using kingdom gold and item" do
		joined, msg = LogQuest.join_quest(@pc, @quest1.id)
		assert joined
		@quest_log = @pc.log_quests.find_by_quest_id(@quest1.id)
		@quest_log.reqs.destroy_all
		@quest_log.complete_quest
		
		@quest_log.quest.kingdom.update_attribute(:gold, 500)
		@quest_log.quest.update_attribute(:item_id, 2)

		assert @pc.items.find(:first, :conditions => ['item_id = ?', 2]).nil?
		assert_difference '@quest_log.quest.kingdom.gold', -(500) do
			assert_difference '@pc.gold', +500 do
				assert_difference '@quest_log.quest.kingdom.kingdom_items.find(:first, :conditions => ["item_id = ?", 2]).quantity', -1 do
					res, msg = @quest_log.collect_reward
					assert res
					@pc.reload
					@pc.items.reload
				end
			end
		end
		assert @pc.items.find(:first, :conditions => ['item_id = ?', 2])
		assert @pc.items.find(:first, :conditions => ['item_id = ?', 2]).quantity == 1
	end
end
