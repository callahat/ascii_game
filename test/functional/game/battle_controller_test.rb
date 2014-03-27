require 'test_helper'

class Game::BattleControllerTest < ActionController::TestCase
	def setup
		session[:player] = Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		session[:player_character][:in_kingdom] = 1
		@creature = Creature.find_by_name("Wimp Monster")
		@level = Level.find(:first, :conditions =>['kingdom_id = ? and level = 0', 1])
		@kl = @level.level_maps.find(:first, :conditions => ['xpos = 2 and ypos = 2'])
	end

	test "king battle" do
		get 'fight_king', {}, session.to_hash
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session.to_hash
		assert_template 'battle'
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "pc battle" do
		session[:current_event] = CurrentEvent.make_new(session[:player_character], @kl.id)
		session[:current_event].update_attribute(:event_id, Event.find_by_name("Sick PC encounter").id)
		get 'fight_pc', {}, session.to_hash
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:enemy_pc)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session.to_hash
		assert_template 'battle'
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "npc battle" do
		session[:current_event] = CurrentEvent.make_new(session[:player_character], @kl.id)
		session[:current_event].update_attribute(:event_id, Event.find_by_name("Healthy Npc encounter").id)
		get 'fight_npc', {}, session.to_hash
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:npc)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}, session.to_hash
		assert_template 'battle'
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "different valid fight options" do
		#pre battle, setup battle
		session[:player_character].c_class.update_attribute(:healing_spells, true)
		session[:player_character].c_class.update_attribute(:attack_spells, true)
		session[:player_character].health.update_attribute(:MP, 300)
		session[:player_character].update_attribute(:level, 300)
		
		session[:current_event] = Event.find_by_name("Weak Monster encounter")
		session[:current_event].happens(session[:player_character])
		get :battle, {}, session.to_hash
		assert_template 'battle'
		
		#conventional
		get 'fight', {:attack => nil}, session.to_hash
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
		
		#healing spell
		get 'fight', {:heal => HealingSpell.find_by_name("Heal Only").id, :commit => "Heal"}, session.to_hash
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
		
		#magic attack, kill all the enemy
		get 'fight', {:attack => AttackSpell.find_by_name("Splash Attack Spell").id, :commit => "Attack"}, session.to_hash
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
	end
	
	test "regicide" do
		get 'fight_king', {}, session.to_hash
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		get 'regicide', {}, session.to_hash
	end
	
	test "run away" do
		get 'fight_king', {}, session.to_hash
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		get 'run_away', {}, session.to_hash
	end
end
