require 'test_helper'

class Game::BattleControllerTest < ActionController::TestCase
	def setup
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:player_character][:in_kingdom] = 1
		@creature = Creature.find_by_name("Wimp Monster")
	end

	test "king battle" do
		get 'fight_king', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "pc battle" do
		session[:current_event] = Event.find_by_name("Sick PC encounter")
		get 'fight_pc', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:enemy_pc)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "npc battle" do
		session[:current_event] = Event.find_by_name("Healthy Npc encounter")
		get 'fight_npc', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:npc)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "creature battle" do
		session[:current_event] = Event.find_by_name("Weak Monster encounter")
		get 'creature', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:e)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "storm the gates" do
		session[:current_event] = Event.find_by_name("Storm Kingdom 1 Gate event")
		get 'storm_the_gates', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_not_nil assigns(:storm_move)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "storm the gates when no guards" do
		session[:current_event] = Event.find_by_name("Storm Kingdom 1 Gate event")
		session[:current_event].event_storm_gate.level.kingdom.guards.destroy_all
		get 'storm_the_gates', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_not_nil assigns(:storm_move)
		assert_response :success
	end
	
	test "different valid fight options" do
		#pre battle, setup battle
		session[:player_character].c_class.update_attribute(:healing_spells, true)
		session[:player_character].c_class.update_attribute(:attack_spells, true)
		session[:player_character].health.update_attribute(:MP, 300)
		session[:player_character].update_attribute(:level, 300)
		
		session[:current_event] = Event.find_by_name("Weak Monster encounter")
		get 'creature', {}, session
		assert_redirected_to :action => 'battle'
		get 'battle', {}, session
		
		#conventional
		get 'fight', {:attack => nil}, session
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
		
		#healing spell
		get 'fight', {:heal => HealingSpell.find_by_name("Heal Only").id, :commit => "Heal"}, session
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
		
		#magic attack, kill all the enemy
		get 'fight', {:attack => AttackSpell.find_by_name("Splash Attack Spell").id, :commit => "Attack"}, session
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
	end
	
	test "regicide" do
		get 'fight_king', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		get 'regicide', {}, session
	end
	
	test "run away" do
		get 'fight_king', {}, session
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		get 'run_away', {}, session
	end
end