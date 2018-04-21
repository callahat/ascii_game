require 'test_helper'

class Management::QuestReqsControllerTest < ActionController::TestCase
  setup do
    @management_quest_req = management_quest_reqs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_quest_reqs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_quest_req" do
    assert_difference('Management::QuestReq.count') do
      post :create, management_quest_req: {  }
    end

    assert_redirected_to management_quest_req_path(assigns(:management_quest_req))
  end

  test "should show management_quest_req" do
    get :show, id: @management_quest_req
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_quest_req
    assert_response :success
  end

  test "should update management_quest_req" do
    patch :update, id: @management_quest_req, management_quest_req: {  }
    assert_redirected_to management_quest_req_path(assigns(:management_quest_req))
  end

  test "should destroy management_quest_req" do
    assert_difference('Management::QuestReq.count', -1) do
      delete :destroy, id: @management_quest_req
    end

    assert_redirected_to management_quest_reqs_path
  end
end
