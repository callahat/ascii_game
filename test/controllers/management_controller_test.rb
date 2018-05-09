require 'test_helper'

class ManagementControllerTest < ActionController::TestCase
  def setup
    sign_in players(:test_player_one)
  end

  test "choose_kingdom" do
    get :choose_kingdom
    assert_response :success
    assert_not_nil assigns(:kingdoms)
  end

  test "main_index" do
    # no kingdom selected
    get :main_index
    assert_redirected_to management_choose_kingdom_path

    session[:kingdom] = player_characters(:test_king).kingdoms.first
    get :main_index
    assert_response :success
    assert_nil assigns(:kingdoms)
  end

  test "helptext" do
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    get :helptext
    assert_response :success
  end

  test "select_kingdom" do
    post :select_kingdom, king: {kingdom_id: kingdoms(:sick_kingdom)}
    assert_redirected_to management_root_path
    assert_equal 'You are not the king in the kingdom submitted!', flash[:notice]
    assert_nil session[:kingdom]

    post :select_kingdom, king: {kingdom_id: kingdoms(:kingdom_one)}
    assert_redirected_to management_root_path
    assert_equal kingdoms(:kingdom_one), session[:kingdom]
  end

  test 'retire' do
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    get :retire
    assert_response :success
  end

  test "retire - abandon" do
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    post :retire, commit:'Abandon'
    assert_response :success
    assert_equal 'Really leave the kingdom without a monarch?', assigns(:message)
  end

  test "retire - give to new king" do
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    post :retire, commit:'Accept', new_king: 'FakeKing'
    assert_response :success
    assert_match /No such character/, assigns(:message)

    post :retire, commit:'Accept', new_king: player_characters(:pc_one).name
    assert_response :success
    assert_match /Really hand the throne over to .*\?/, assigns(:message)
    assert_equal player_characters(:pc_one), session[:new_king]

    post :retire, commit:'Accept', new_king: player_characters(:test_hollow_pc).name
    assert_response :success
    assert_match /Really hand the throne over to .* of .*\?/, assigns(:message)
    assert_equal player_characters(:test_hollow_pc), session[:new_king]
  end

  test "do_retire - cancelled" do
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    post :do_retire, commit: 'Cancel'
    assert_redirected_to management_retire_path
  end

  test "do_retire - invalid or no successor" do
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    post :do_retire, commit: 'Confirm'
    assert_nil kingdoms(:kingdom_one).player_character
    assert_redirected_to main_game_path
    assert_nil session[:kingdom]
    refute session[:king_bit]
  end

  test "do_retire - valid no successor" do
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    session[:new_king] = player_characters(:test_hollow_pc)
    post :do_retire, commit: 'Confirm'
    assert_equal player_characters(:test_hollow_pc), kingdoms(:kingdom_one).player_character
    assert_redirected_to main_game_path
    assert_nil session[:kingdom]
    refute session[:king_bit]
  end
end
