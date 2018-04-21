require 'test_helper'

class Management::QuestsControllerTest < ActionController::TestCase
  setup do
    @management_quest = management_quests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_quests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_quest" do
    assert_difference('Management::Quest.count') do
      post :create, management_quest: {  }
    end

    assert_redirected_to management_quest_path(assigns(:management_quest))
  end

  test "should show management_quest" do
    get :show, id: @management_quest
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_quest
    assert_response :success
  end

  test "should update management_quest" do
    patch :update, id: @management_quest, management_quest: {  }
    assert_redirected_to management_quest_path(assigns(:management_quest))
  end

  test "should destroy management_quest" do
    assert_difference('Management::Quest.count', -1) do
      delete :destroy, id: @management_quest
    end

    assert_redirected_to management_quests_path
  end
end
