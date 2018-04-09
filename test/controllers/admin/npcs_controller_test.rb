require 'test_helper'

class Admin::NpcsControllerTest < ActionController::TestCase
  setup do
    @npc = npcs(:npc_one)
    session[:player] = players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:npcs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create npc" do
    assert_difference('Npc.count') do
      post :create, npc: @npc.attributes_with_nesteds.merge(name: 'New NPC')
    end

    assert_redirected_to admin_npc_path(assigns(:npc))
  end

  test "should show npc" do
    get :show, id: @npc
    assert_response :success
  end

  test "should show guard npc" do
    get :show, id: npcs(:guard_1)
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @npc
    assert_response :success
  end

  test "should edit guard npc" do
    get :edit, id: npcs(:guard_1)
    assert_response :success
  end

  test "should update npc" do
    patch :update, id: @npc, npc: @npc.attributes_with_nesteds.merge( name: 'Updated NPC' )
    assert_redirected_to admin_npc_path(assigns(:npc))
  end

  test "should destroy npc" do
    assert_difference('Npc.count', -1) do
      delete :destroy, id: @npc
    end

    assert_redirected_to admin_npcs_path
  end
end
