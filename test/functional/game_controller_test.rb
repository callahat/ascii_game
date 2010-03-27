require 'test_helper'

class GameControllerTest < ActionController::TestCase
	def setup
		@creature = Creature.find_by_name("Wimp Monster")
		@level = Level.find(:first, :conditions =>['kingdom_id = ? and level = 0', 1])
		@level_map = @level.level_maps.find(:first, :conditions => ['feature_id is not null'])
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:player_character][:in_kingdom] = 1
		session[:player_character].present_level = @level
	end

	test "game controller main" do
		session[:player_character] = nil
		get 'main', {}, session
		assert_response :redirect
		assert_redirected_to :controller => 'character'
		
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		get 'main', {}, session
		assert_response :success
		assert_not_nil assigns(:where)
		assert_template 'main'
	end
	
	test "game controller leave kingdom" do
		get 'leave_kingdom', {}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].in_kingdom.nil?
		assert session[:player_character].kingdom_level.nil?
	end
	
	test "game controller world moves" do
		session[:player_character].in_kingdom = nil?
		session[:player_character].kingdom_level = nil?
		
		post 'world_move', {:id => 'north'}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == -1
		assert flash[:notice] =~ /[Nn]orth/
		
		post 'world_move', {:id => 'north'}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == -1
		assert flash[:notice] =~ /invalid/
		
		post 'world_move', {:id => 'west'}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == -1
		assert flash[:notice] =~ /invalid/
		
		post 'world_move', {:id => 'south'}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /[Ss]outh/
		
		post 'world_move', {:id => 'east'}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].bigx == 1
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /[Ee]ast/
		
		post 'world_move', {:id => 'east'}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].bigx == 1
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /invalid/
		
		post 'world_move', {:id => 'west'}, session
		assert_response :redirect
		assert_redirected_to :action => 'main'
		assert session[:player_character].bigx == 0
		assert session[:player_character].bigy == 0
		assert flash[:notice] =~ /[Ww]est/
	end
	
	
	test "game controller feature action when not loged in or character selected" do
		session[:player] = nil
		session[:player_character] = nil
		
		get 'feature', {:id => @level_map.id}, session
		assert_response :success
		assert_template 'demo'
		
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		get 'feature', {:id => @level_map.id}, session
		assert_response :success
		assert_template 'demo'
		
		session[:player_character] = nil
		session[:player] = Player.find_by_handle("Test Player One")
		get 'feature', {:id => @level_map.id}, session
		assert_redirected_to :controller => 'character', :action => 'choose'
		
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		get 'feature', {}, session
		assert_redirected_to :action => 'main'
	end
	
	test "game controller feature action when battle exists" do
		@pc = session[:player_character]
		battle, msg = Battle.new_creature_battle(@pc, @creature, 5, 5, @pc.in_kingdom)
		assert battle
		
		get 'feature', {}, session
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
		
		get 'feature', {:id => @level_map.id}, session
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
	end
	
	test "game controller feature action when not enough turns" do
		session[:player_character].update_attribute(:turns,0)
		@kl = @level.level_maps.find(:first, :conditions => ['xpos = 1 and ypos = 1'])
		
		get 'feature', {:id => @kl.id}, session
		assert_redirected_to :controller => 'game', :action => 'main'
		assert flash[:notice] =~ /tired/
		
		#using no parameters for the get causes the controller to behave as if there is a current event, which
		#hits the controller, and reaches the exec_event function, and hits nil for the event name
		#get 'feature', {}, session
		#assert_redirected_to :controller => 'game', :action => 'main'
		#assert flash[:notice] =~ /tired/, flash[:notice].inspect
	end
	
	test "game controller feature action where no choice fight creature" do
		@kl = @level.level_maps.find(:first, :conditions => ['xpos = 1 and ypos = 1'])
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session
		end
		
		assert_response :redirect
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
		
		assert session[:player_character].current_event.location_id == @kl.id
		assert session[:player_character].battle
		
		#not really completed, so following the trail returns us to the battle
		get 'complete', {}, session
		assert_redirected_to :controller => 'game', :action => 'feature'
		
		get 'feature', {}, session
		assert_redirected_to :controller => 'game/battle', :action => 'battle'
		
		session[:player_character].current_event.update_attribute(:completed, EVENT_COMPLETED)

		get 'complete', {}, session
		session[:player_character].reload
		session[:player_character].current_event
		assert_redirected_to :controller => 'game', :action => 'main'
		assert session[:player_character].current_event.nil?
	end
	
	test "game controller feature action where nothing happens" do
		@kl = @level.level_maps.find(:first, :conditions => ['xpos = 2 and ypos = 2'])
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session
		end
		assert_redirected_to :controller => 'game', :action => 'main'
		assert flash[:notice] =~ /Nothing/
		assert session[:player_character].current_event.nil?
	end
	
	test "game controller feature action where there are choices then choose" do
		@kl = @level.level_maps.find(:first, :conditions => ['xpos = 0 and ypos = 0'])
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session
		end
		assert_response :success
		assert_template 'choose'
		assert session[:ev_choices]
		
		get 'do_choose', {:id => 1}, session
		assert_response :redirect
		assert_redirected_to :controller => 'game', :action => 'feature'
		assert session[:player_character].current_event.event_id.nil?
		
		post 'do_choose', {:id => 1}, session
		assert_response :success
		assert_template 'choose'
		assert flash[:notice] =~ /Invalid/
		assert session[:player_character].current_event.event_id.nil?
		
		post 'do_choose', {:id => session[:ev_choices][0].id}, session
		assert_response :redirect
		assert session[:ev_choices].nil?
		assert session[:player_character].current_event.event_id
	end
	
	test "game controller feature action where there are choices then skip" do
		@kl = @level.level_maps.find(:first, :conditions => ['xpos = 0 and ypos = 0'])
		
		assert_difference 'session[:player_character].turns', -1 do
			get 'feature', {:id => @kl.id}, session
		end
		assert_response :success
		assert_template 'choose'
		assert session[:ev_choices]
		
		post 'do_choose', {}, session
		session[:player_character].reload
		assert_redirected_to :controller => 'game', :action => 'complete'
		assert session[:ev_choices].nil?
		
		get 'complete', {}, session
		assert_redirected_to :controller => 'game', :action => 'feature'
		assert session[:player_character].current_event.event_id.nil?, session[:player_character].current_event
		
		assert_difference 'session[:player_character].current_event.priority', +1 do
			get 'feature', {}, session
		end
		assert_response :success
		assert session[:player_character].current_event.event_id
	end
end
