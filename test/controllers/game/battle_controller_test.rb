require 'test_helper'

class Game::BattleControllerTest < ActionController::TestCase
	def setup
		sign_in Player.find_by_handle("Test Player One")
		session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
		@creature = Creature.find_by_name("Wimp Monster")
		@level = kingdoms(:kingdom_one).levels.where(level: 0).first
		@kl = @level.level_maps.where(xpos: 2, ypos: 2).first
	end

	test "king battle" do
		get 'fight_king'
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}
		assert_template 'battle'
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "pc battle" do
		session[:player_character].current_event = CurrentEvent.make_new(session[:player_character], @kl.id)
		session[:player_character].current_event.update_attribute(:event_id, Event.find_by_name("Sick PC encounter").id)
		get 'fight_pc', {}
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:enemy_pc)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}
		assert_template 'battle'
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end
	
	test "npc battle" do
		session[:player_character].current_event = CurrentEvent.make_new(session[:player_character], @kl.id)
		session[:player_character].current_event.update_attribute(:event_id, Event.find_by_name("Healthy Npc encounter").id)
		get 'fight_npc', {}
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:npc)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		
		get 'battle', {}
		assert_template 'battle'
		
		assert_response :success
		assert_not_nil assigns(:battle)
	end

  test "battle" do
    # battle.nil?
    get :battle
    assert_redirected_to main_game_path

    battle, msg = Battle.new_creature_battle(session[:player_character], @creature, 1, 1, nil)
    assert battle
    assert session[:player_character].reload.battle
    session[:player_character].health.update_attribute :HP, 0
    get :battle
    assert_template 'game/complete'
    assert_nil session[:player_character].reload.battle
    assert_match /You have been killed/, response.body

    session[:player_character].health.update_attribute :HP, 10
    battle, msg = Battle.new_creature_battle(session[:player_character], @creature, 1, 1, nil)
    assert battle
    battle.enemies.destroy_all
    battle.update_attribute :gold, 500
    assert session[:player_character].reload.battle
    assert_difference 'session[:player_character].gold', +475 do
      get :battle
      assert_template 'game/complete'
      assert_nil session[:player_character].reload.battle
    end

    battle, msg = Battle.new_creature_battle(session[:player_character], @creature, 1, 1, nil)
    assert battle
    assert session[:player_character].reload.battle
    session[:regicide] = true
    get :battle
    assert_redirected_to regicide_game_battle_path
  end

	test "different valid fight options" do
		#pre battle, setup battle
		session[:player_character].c_class.update_attribute(:healing_spells, true)
		session[:player_character].c_class.update_attribute(:attack_spells, true)
		session[:player_character].health.update_attribute(:MP, 300)
		session[:player_character].update_attribute(:level, 300)
		
		session[:player_character].current_event = CurrentKingdomEvent.new event: events(:creature_event),
																																			 location: level_maps(:test_level_map_0_2),
																																			 priority: 1
		session[:player_character].current_event.event.happens(session[:player_character])
		get :battle, {}
		assert_template 'battle'
		
		#conventional
		get 'fight', {:attack => nil}
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
		
		#healing spell
		get 'fight', {:heal => HealingSpell.find_by_name("Heal Only").id, :commit => "Heal"}
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
		
		#magic attack, kill all the enemy
		get 'fight', {:attack => AttackSpell.find_by_name("Splash Attack Spell").id, :commit => "Attack"}
		assert_not_nil flash[:battle_report]
		assert_redirected_to :action => 'battle'
	end
	
	test "regicide" do
		get 'fight_king'
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'

    get 'regicide'
    assert_redirected_to feature_game_path

    session[:regicide] = kingdoms(:kingdom_one).id
    get 'regicide'
    assert_response :success
    assert_not_nil assigns(:kingdom)
	end

  test "fate_of_throne - abandon" do
    @kingdom = kingdoms(:kingdom_one)
    post :fate_of_throne, q: 'abandon'
    assert_redirected_to action: :battle

    get 'fight_king'
    session[:regicide] = @kingdom.id
    post :fate_of_throne, q: 'abandon'
    assert_template 'game/complete'
    assert_nil @kingdom.reload.player_character
  end

  test "fate_of_throne - keep_fighting" do
    get 'fight_king'
    @kingdom = kingdoms(:kingdom_one)
    session[:regicide] = @kingdom.id
    post :fate_of_throne, q: 'keep_fighting'
    assert_redirected_to action: :battle
    assert_equal session[:player_character].id, @kingdom.reload.player_character_id
  end

  test "fate_of_throne - claim" do
    get 'fight_king'
    @kingdom = kingdoms(:kingdom_one)
    session[:regicide] = @kingdom.id
    post :fate_of_throne, q: 'claim'
    assert_template 'game/complete'
    assert_equal session[:player_character].id, @kingdom.reload.player_character_id
  end

	test "run away" do
		get 'fight_king', {}
		assert_not_nil assigns(:pc)
		assert_not_nil assigns(:kingdom)
		assert_response :redirect
		assert_redirected_to :action => 'battle'
		get 'run_away', {}
	end
end
