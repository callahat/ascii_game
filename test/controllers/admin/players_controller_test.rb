require 'test_helper'

class Admin::PlayersControllerTest < ActionController::TestCase
  setup do
    @player = players(:test_player_one)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:players)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create player" do
    assert_difference('Player.count') do
      post :create, player: @player.attributes.merge(
                      handle: 'New Playa',
                      password: 'Goof123456',
                      email: 'system@example.com')
    end

    assert_redirected_to admin_player_path(assigns(:player))
  end

  test "should show player" do
    get :show, id: @player
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @player
    assert_response :success
  end

  test "should update player" do
    patch :update, id: @player, player: { bio: 'updated bio' }
    assert_redirected_to admin_player_path(assigns(:player)), assigns(:player).errors.full_messages
  end

  # test "should destroy player" do
  #   assert_difference('Player.count', -1) do
  #     delete :destroy, id: @player
  #   end
  #
  #   assert_redirected_to admin_players_path
  # end
end
