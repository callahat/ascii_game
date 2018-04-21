require 'test_helper'

class Management::KingdomNpcsControllerTest < ActionController::TestCase
  setup do
    @management_kingdom_npc = management_kingdom_npcs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_kingdom_npcs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_kingdom_npc" do
    assert_difference('Management::KingdomNpc.count') do
      post :create, management_kingdom_npc: {  }
    end

    assert_redirected_to management_kingdom_npc_path(assigns(:management_kingdom_npc))
  end

  test "should show management_kingdom_npc" do
    get :show, id: @management_kingdom_npc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_kingdom_npc
    assert_response :success
  end

  test "should update management_kingdom_npc" do
    patch :update, id: @management_kingdom_npc, management_kingdom_npc: {  }
    assert_redirected_to management_kingdom_npc_path(assigns(:management_kingdom_npc))
  end

  test "should destroy management_kingdom_npc" do
    assert_difference('Management::KingdomNpc.count', -1) do
      delete :destroy, id: @management_kingdom_npc
    end

    assert_redirected_to management_kingdom_npcs_path
  end
end
