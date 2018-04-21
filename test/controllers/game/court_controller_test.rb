require 'test_helper'

class Game::CourtControllerTest < ActionController::TestCase
  def setup
    @player = players(:test_player_one)
    @kingdom = kingdoms(:kingdom_one)
    sign_in @player
    session[:player_character] = PlayerCharacter.find_by_name("Test PC One")
    session[:player_character].present_kingdom = @kingdom
  end

  test "throne" do
    get :throne
    assert_response :success
    assert assigns(:king_on_throne)
    assert_equal player_characters(:test_king), assigns(:king_on_throne)
  end

  test "join_king" do
    assert_not_equal session[:player_character].in_kingdom, session[:player_character].kingdom_id
    post :join_king
    assert_response :success
    assert_equal session[:player_character].in_kingdom, session[:player_character].kingdom_id
    assert_template 'complete'
  end

  test "king_me when a king is there" do
    assert_no_difference 'session[:player_character].present_kingdom.player_character_id' do
      post :king_me
      assert_response :success
      assert assigns(:king)
      assert_match /King #{assigns(:king).name} glowers at your attempt to sit upon his throne\./, response.body
      assert_not_equal @kingdom.player_character_id, session[:player_character].id
      assert_template 'complete'
    end
  end

  test "king_me when too low a level" do
    @kingdom.update_attribute :player_character_id, nil
    session[:player_character].update_attribute :level, 2

    post :king_me
    assert_response :success
    assert_match /The steward approaches "You are yet not strong enough to claim the crown\."/, response.body
    assert_not_equal @kingdom.player_character_id, session[:player_character].id
    assert_template 'complete'
  end

  test "king_me when just right" do
    @kingdom.update_attribute :player_character_id, nil
    session[:player_character].update_attribute :level, 15

    assert_difference 'KingdomNotice.count', +1 do
      post :king_me
      assert_response :success
      assert_match /You have claimed the crown/, response.body
      assert_equal @kingdom.player_character_id, session[:player_character].id
      assert_template 'complete'
    end
  end

  test "castle" do
    get :castle
    assert_response :success
    assert assigns(:kingdom)
    assert_equal assigns(:kingdom), session[:player_character].present_kingdom
  end

  test "bulletin" do
    get :bulletin
    assert_response :success
    assert assigns(:notices)
    assert_template 'bulletin'
  end
end
