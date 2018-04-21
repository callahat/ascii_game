require 'test_helper'

class Management::KingdomBansControllerTest < ActionController::TestCase
  setup do
    @management_kingdom_ban = management_kingdom_bans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_kingdom_bans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_kingdom_ban" do
    assert_difference('Management::KingdomBan.count') do
      post :create, management_kingdom_ban: {  }
    end

    assert_redirected_to management_kingdom_ban_path(assigns(:management_kingdom_ban))
  end

  test "should show management_kingdom_ban" do
    get :show, id: @management_kingdom_ban
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_kingdom_ban
    assert_response :success
  end

  test "should update management_kingdom_ban" do
    patch :update, id: @management_kingdom_ban, management_kingdom_ban: {  }
    assert_redirected_to management_kingdom_ban_path(assigns(:management_kingdom_ban))
  end

  test "should destroy management_kingdom_ban" do
    assert_difference('Management::KingdomBan.count', -1) do
      delete :destroy, id: @management_kingdom_ban
    end

    assert_redirected_to management_kingdom_bans_path
  end
end
