require 'test_helper'

class Game::QuestsControllerTest < ActionController::TestCase
	def setup
		@controller = Game::QuestsController.new
		@request  = ActionController::TestRequest.new
		@response = ActionController::TestResponse.new
	
		@level = Level.where(['kingdom_id = ? and level = 0', 1]).first
		@level_map = @level.level_maps.where(['feature_id is not null']).first
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:player_character][:in_kingdom] = 1
		session[:player_character].present_level = @level
		
		@quest_one = Quest.find_by_name("Quest One")
		@kl1 = @level.level_maps.where(['xpos = 1 and ypos = 0']).first
		@kl2 = @level.level_maps.where(['xpos = 2 and ypos = 0']).first
	end
	
	def setup_sub1
		CurrentEvent.make_new(session[:player_character], @kl1.id)
		@next, @it = session[:player_character].current_event.next_event
		session[:player_character].current_event.update_attributes(:event_id => @it.id, :priority => @next)
		@direction, @completed, @message = session[:player_character].current_event.event.happens(session[:player_character])
		session[:player_character].current_event.update_attribute(:completed, @completed)
		session[:player_character].reload
		assert_equal EventQuest, session[:player_character].current_event.event.class
	end
	
	def setup_sub2
		setup_sub1
		LogQuest.join_quest(session[:player_character], @quest_one.id)
		assert @log_quest = session[:player_character].log_quests.find_by_quest_id(@quest_one.id)
		assert @log_quest.reqs.size == 6
	end

	test "quest controller index decline" do
		setup_sub1
		
		get 'index', {}, session.to_hash
		assert_response :success
		assert session[:player_character].current_event.completed == EVENT_FAILED
		
		assert_difference 'session[:player_character].log_quests.size', +0 do
			get 'do_decline', {}, session.to_hash
			assert_response :success
			assert_template 'complete'
			session[:player_character].log_quests.reload
		end
	end
	
	test "quest controller index join" do
		setup_sub1
		
		get 'index', {}, session.to_hash
		assert_response :success
		assert session[:player_character].current_event.completed == EVENT_FAILED
		
		assert session[:player_character].log_quests.find_by_quest_id(@quest_one.id).nil?
		assert_difference 'session[:player_character].log_quests.size', +1 do
			get 'do_join', {}, session.to_hash
			assert_response :success
			assert_template 'complete'
			session[:player_character].log_quests.reload
		end
		assert session[:player_character].log_quests.find_by_quest_id(@quest_one.id)
		assert session[:player_character].log_quests.find_by_quest_id(@quest_one.id).reqs.size == 6
	end
	
	test "quest controller do complete and reward" do
		setup_sub2
		
		get 'do_complete', {}, session.to_hash
		assert_redirected_to quest_index_url()

		assert_difference '@log_quest.quest.kingdom.gold', +0 do
			assert_difference 'session[:player_character].gold', +0 do
				assert_difference 'session[:player_character].current_event.completed', +0 do
					get 'do_reward', {}, session.to_hash
					assert_redirected_to quest_index_url()
				end
			end
		end
		
		@log_quest.reqs.destroy_all
		
		@log_quest.quest.kingdom.update_attribute(:gold, 0)
		
		get 'do_complete', {}, session.to_hash
		assert_redirected_to do_reward_quest_url()
		
		assert_difference 'session[:player_character].current_event.completed', +0 do
			get 'do_reward', {}, session.to_hash
			assert_redirected_to quest_index_url()
		end
		
		@log_quest.quest.kingdom.update_attribute(:gold, 100000)
		
		assert_difference '@log_quest.quest.kingdom.gold', -@quest_one.gold do
			assert_difference 'session[:player_character].gold', +@quest_one.gold do
				get 'do_reward', {}, session.to_hash
				assert_redirected_to quest_index_url()
				assert session[:player_character].current_event.completed == EVENT_COMPLETED
				@log_quest.quest.kingdom.reload
				session[:player_character].reload
			end
		end
	end
end
