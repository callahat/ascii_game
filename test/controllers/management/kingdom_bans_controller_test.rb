require 'test_helper'

class Management::KingdomBansControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    @kingdom_ban = kingdom_bans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kingdom_bans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kingdom_ban" do
    assert_difference('KingdomBan.count') do
      post :create, kingdom_ban: { name: "Test PC One" }
    end

    assert_redirected_to management_kingdom_bans_path
  end

  test "should show management_kingdom_ban" do
    get :show, id: @kingdom_ban
    assert_response :success
  end

  test "should destroy kingdom_ban" do
    assert_difference('KingdomBan.count', -1) do
      delete :destroy, id: @kingdom_ban
    end

    assert_redirected_to management_kingdom_bans_path
  end
end
