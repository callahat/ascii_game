require 'test_helper'

class Game::QuestsControllerTest < ActionController::TestCase
	def setup
		@controller = Game::QuestsController.new
		@request  = ActionController::TestRequest.new
		@response = ActionController::TestResponse.new
	
		@level = kingdoms(:kingdom_one).levels.where(level: 0).first
		@level_map = @level.level_maps.where(['feature_id is not null']).first
		sign_in Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:player_character].present_level = @level
		
		@quest_one = Quest.find_by_name("Quest One")
		@kl1 = @level.level_maps.where(xpos: 1, ypos: 0).first
		@kl2 = @level.level_maps.where(xpos: 2, ypos: 0).first
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

	test "quest controller show decline" do
		setup_sub1
		
		get 'show', {}
		assert_response :success
		assert session[:player_character].current_event.completed == EVENT_FAILED
		
		assert_difference 'session[:player_character].log_quests.size', +0 do
			post 'do_decline', {}
			assert_response :success
			assert_template 'complete'
			session[:player_character].log_quests.reload
		end
	end
	
	test "quest controller show join" do
		setup_sub1
		
		get 'show', {}
		assert_response :success
		assert session[:player_character].current_event.completed == EVENT_FAILED
		
		assert session[:player_character].log_quests.find_by_quest_id(@quest_one.id).nil?
		assert_difference 'session[:player_character].log_quests.size', +1 do
			post 'do_join', {}
			assert_response :success
			assert_template 'complete'
			session[:player_character].log_quests.reload
		end
		assert session[:player_character].log_quests.find_by_quest_id(@quest_one.id)
		assert session[:player_character].log_quests.find_by_quest_id(@quest_one.id).reqs.size == 6
	end
	
	test "quest controller do complete and reward" do
		setup_sub2
		
		get 'do_complete', {}
		assert_redirected_to game_quests_path

		assert_difference '@log_quest.quest.kingdom.gold', +0 do
			assert_difference 'session[:player_character].gold', +0 do
				assert_difference 'session[:player_character].current_event.completed', +0 do
					get 'do_reward', {}
					assert_redirected_to game_quests_path
				end
			end
		end
		
		@log_quest.reqs.destroy_all
		
		@log_quest.quest.kingdom.update_attribute(:gold, 0)
		
		get 'do_complete', {}
		assert_redirected_to do_reward_game_quests_path
		
		assert_difference 'session[:player_character].current_event.completed', +0 do
			get 'do_reward', {}
			assert_redirected_to game_quests_path
		end
		
		@log_quest.quest.kingdom.update_attribute(:gold, 100000)
		
		assert_difference '@log_quest.quest.kingdom.gold', -@quest_one.gold do
			assert_difference 'session[:player_character].gold', +@quest_one.gold do
				get 'do_reward', {}
				assert_redirected_to game_quests_path
				assert session[:player_character].current_event.completed == EVENT_COMPLETED
				@log_quest.quest.kingdom.reload
				session[:player_character].reload
			end
		end
	end
end
