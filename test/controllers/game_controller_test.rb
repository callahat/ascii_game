require 'test_helper'

class GameControllerTest < ActionController::TestCase
	def setup
		@controller = GameController.new
		@request  = ActionController::TestRequest.new
		@response = ActionController::TestResponse.new
	
		@creature = Creature.find_by_name("Wimp Monster")
		@level = kingdoms(:kingdom_one).levels.where(level: 0).first
		@level_map = @level.level_maps.where(['feature_id is not null']).first
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:player_character].present_level = @level
	end

	test "game controller main" do
		#p "game controller main"
		session[:player_character] = nil
		get 'main', {}, session.to_hash
		assert_response :redirect
		assert_redirected_to character_url()
		
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		#p "WAAA"
		get 'main', {}, session.to_hash
		#p "AAAW"
		assert_response :success
		assert_not_nil assigns(:where)
		assert_template 'main'
	end
	
	test "game controller leave kingdom" do
		get 'leave_kingdom', {}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].in_kingdom.nil?
		assert session[:player_character].kingdom_level.nil?
	end
	
	test "game controller world moves" do
		session[:player_character].in_kingdom = nil?
		session[:player_character].kingdom_level = nil?
		
		post 'world_move', {:id => 'north'}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == -1
		assert flash[:notice] =~ /[Nn]orth/
		
		post 'world_move', {:id => 'north'}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == -1
		assert flash[:notice] =~ /invalid/
		
		post 'world_move', {:id => 'west'}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == -1
		assert flash[:notice] =~ /invalid/
		
		post 'world_move', {:id => 'south'}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /[Ss]outh/
		
		post 'world_move', {:id => 'east'}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].bigx == 1
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /[Ee]ast/
		
		post 'world_move', {:id => 'east'}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].bigx == 1
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /invalid/
		
		post 'world_move', {:id => 'west'}, session.to_hash
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /[Ww]est/
	end
	
	
	test "game controller feature action when not loged in or character selected" do
		session[:player] = nil
		session[:player_character] = nil
		
		get 'feature', {:id => @level_map.id}, session.to_hash
		assert_response :redirect
		
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		get 'feature', {:id => @level_map.id}, session.to_hash
		assert_response :redirect
		
		session[:player_character] = nil
		session[:player] = Player.find_by_handle("Test Player One")
		get 'feature', {:id => @level_map.id}, session.to_hash
		assert_redirected_to character_url()
		
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		get 'feature', {}, session.to_hash
		assert_redirected_to game_main_url()
	end
	
	test "game controller feature action when battle exists" do
		@pc = session[:player_character]
		battle, msg = Battle.new_creature_battle(@pc, @creature, 5, 5, @pc.in_kingdom)
		assert battle
		
		get 'feature', {}, session.to_hash
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
		
		get 'feature', {:id => @level_map.id}, session.to_hash
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
	end
	
	test "game controller feature action when not enough turns" do
		session[:player_character].update_attribute(:turns,0)
		@kl = @level.level_maps.where(['xpos = 1 and ypos = 1']).first
		
		get 'feature', {:id => @kl.id}, session.to_hash
		assert_redirected_to :controller => 'game', :action => 'main'
		assert flash[:notice] =~ /tired/
		
		#using no parameters for the get causes the controller to behave as if there is a current event, which
		#hits the controller, and reaches the exec_event function, and hits nil for the event name
		#get 'feature', {}, session.to_hash
		#assert_redirected_to :controller => 'game', :action => 'main'
		#assert flash[:notice] =~ /tired/, flash[:notice].inspect
	end
	
	test "game controller feature action where no choice fight creature" do
		@kl = @level.level_maps.where(['xpos = 1 and ypos = 1']).first
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session.to_hash
		end
		
		assert_response :redirect
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
		
		assert session[:player_character].current_event.location_id == @kl.id
		assert session[:player_character].battle
		
		#not really completed, so following the trail returns us to the battle
		get 'complete', {}, session.to_hash
		assert_redirected_to :controller => 'game', :action => 'feature'
		
		get 'feature', {}, session.to_hash
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
		
		session[:player_character].current_event.update_attribute(:completed, EVENT_COMPLETED)

		get 'complete', {}, session.to_hash
		session[:player_character].reload
		session[:player_character].current_event
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].current_event.nil?
	end
	
	test "game controller feature action where nothing happens" do
		@kl = @level.level_maps.where(['xpos = 2 and ypos = 2']).first
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session.to_hash
		end
		assert_redirected_to :controller => 'game', :action => 'main'
		assert flash[:notice] =~ /Nothing/
		assert session[:player_character].current_event.nil?
	end
	
	test "game controller feature action where there are choices then choose" do
		@kl = @level.level_maps.where(['xpos = 0 and ypos = 0']).first
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session.to_hash
		end
		assert_response :success
		assert_template 'choose'
		assert session[:ev_choices]
		
		get 'do_choose', {:id => 1}, session.to_hash
		assert_response :success
		assert_template 'choose'
		assert flash[:notice] =~ /Invalid/
		assert session[:player_character].current_event.event_id.nil?
		
		post 'do_choose', {:id => 1}, session.to_hash
		assert_response :success
		assert_template 'choose'
		assert flash[:notice] =~ /Invalid/
		assert session[:player_character].current_event.event_id.nil?
		
		post 'do_choose', {:id => session[:ev_choices][0].id}, session.to_hash
		assert_response :redirect
		assert session[:ev_choices].nil?
		assert session[:player_character].current_event.event_id
	end
	
	test "game controller feature action where there are choices then skip" do
		@kl = @level.level_maps.where(['xpos = 0 and ypos = 0']).first
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session.to_hash
		end
		assert_response :success
		assert_template 'choose'
		assert session[:ev_choices]
		
		post 'do_choose', {}, session.to_hash
		session[:player_character].reload
		assert_redirected_to :controller => 'game', :action => 'complete'
		assert session[:ev_choices].nil?
		
		get 'complete', {}, session.to_hash
		assert_redirected_to :controller => 'game', :action => 'feature'
		refute session[:player_character].current_event.event_id
		
		assert_difference 'session[:player_character].current_event.priority', +1 do
			get 'feature', {}, session.to_hash
		end
		assert_response :success
		assert session[:player_character].current_event.event_id
	end
	
	test "game controller spawn kingdom" do
		session[:player_character].update_attribute(:in_kingdom, nil)
		session[:player_character].update_attribute(:kingdom_level, nil)
		@world_map = WorldMap.where(xpos: 1, ypos: 1, bigxpos: 0, bigypos: -1).last
		get 'spawn_kingdom', {}, session.to_hash
		assert_response :success
		assert_template 'spawn_kingdom'
		
		##no current event
		assert_no_difference 'Kingdom.count' do
			post 'do_spawn', {:kingdom => {:name => 'Awesomeland'}}, session.to_hash
		end
		assert_redirected_to :controller => 'game', :action => 'feature'
		
		#Try feature even when level too low
		get 'feature', {:id => @world_map.id}, session.to_hash
		assert_redirected_to :controller => 'game', :action => 'complete'
		assert flash[:notice] =~ /not yet powerful/
		
		get 'complete', {}, session.to_hash
		assert_redirected_to game_main_url()
		
		#try feature with high enough level
		session[:player_character].update_attribute(:level, 50)
		get 'feature', {:id => @world_map.id}, session.to_hash
		
		assert_redirected_to :controller => 'game', :action => 'spawn_kingdom'
		assert_no_difference 'Kingdom.count' do
			post 'do_spawn', {:kingdom => {:name => 'HealthyTestKingdom'}}, session.to_hash
		end
		assert_template 'spawn_kingdom'
		assert_difference 'Kingdom.count', +1 do
			post 'do_spawn', {:kingdom => {:name => 'Awesomeland'}}, session.to_hash
		end
		assert_redirected_to :controller => 'game', :action => 'complete'
	end

	test "game controller quest event" do
		@quest_one = Quest.find_by_name("Quest One")
		@kl1 = @level.level_maps.where(['xpos = 1 and ypos = 0']).first
		@kl2 = @level.level_maps.where(['xpos = 2 and ypos = 0']).first
		
		get 'feature', {:id => @kl1.id}, session.to_hash
		assert_response :redirect
		assert_redirected_to quest_index_url()
		
		session[:player_character].current_event.destroy
		
		get 'feature', {:id => @kl2.id}, session.to_hash
		assert_response :redirect
		assert_redirected_to  :controller => 'game/quests', :action => 'index'
		#Will be nil when it hits the filter in the quests controller
		#assert session[:player_character].current_event.nil?
		
		session[:player_character].current_event.destroy
		
		LogQuest.join_quest(session[:player_character], @quest_one.id)
		@lq = session[:player_character].log_quests.where(['quest_id = ?', @quest_one.id]).first
		@lq.reqs.destroy_all
		
		res, msg = @lq.complete_quest
		assert res, msg.inspect
		
		get 'feature', {:id => @kl2.id}, session.to_hash
		assert_response :redirect
		session[:player_character].current_event.destroy
		
		get 'feature', {:id => @kl1.id}, session.to_hash
		assert_response :redirect
		assert_redirected_to do_complete_quest_url()
		assert session[:player_character].current_event.completed == EVENT_COMPLETED
		
		@lq.quest.kingdom.update_attribute(:gold, 10000000)
		
		res, msg = @lq.collect_reward
		
		assert res, msg
		get 'feature', {:id => @kl1.id}, session.to_hash
		assert_response :redirect
		assert_redirected_to  :controller => 'game', :action => 'main'
		assert session[:player_character].current_event.completed == EVENT_COMPLETED
	end
end
