require 'test_helper'

class Management::QuestsControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    @quest = quests(:quest_one)
    # @quest.update_attribute :quest_status, SpecialCode.get_code('quest_status', 'design')
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quests)
  end

  test "should show management_quest" do
    get :show, id: @quest
    assert_response :success
    assert_not_nil assigns(:quest)
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:quest)
    assert_not_nil assigns(:prereqs)
  end

  test "should create quest" do
    assert_no_difference('Quest.count') do
      post :create, quest: @quest.attributes.merge(name: '')
    end

    assert_difference('Quest.count') do
      post :create, quest: @quest.attributes.merge(name: 'New Quest')
    end
    assert_redirected_to management_quest_path(assigns(:quest))
  end

  test "should get edit" do
    get :edit, id: @quest
    assert_response :success
    assert_not_nil assigns(:quest)
    assert_not_nil assigns(:prereqs)
  end

  test "should update quest" do
    # invalid
    patch :update, id: @quest, quest: { name: '' }
    assert template: :edit

    # quest active
    patch :update, id: @quest, quest: { name: 'NewName' }
    assert_redirected_to management_quests_path
    assert_match /cannot be edited; it is already being used/, flash[:notice]

    # just right
    @quest.update_attribute :quest_status, SpecialCode.get_code('quest_status', 'design')
    patch :update, id: @quest, quest: { name: 'NewName' }
    assert_redirected_to management_quest_path(assigns(:quest))
  end

  test "activate" do
    @quest.update_attribute :quest_status, SpecialCode.get_code('quest_status', 'design')
    post :activate, id: @quest
    assert_redirected_to management_quests_path
    assert_equal SpecialCode.get_code('quest_status','active'), @quest.reload.quest_status

    @quest.update_attribute :quest_status, SpecialCode.get_code('quest_status', 'design')
    @quest.reqs.destroy_all
    post :activate, id: @quest
    assert_redirected_to management_quests_path
    assert_equal SpecialCode.get_code('quest_status','design'), @quest.reload.quest_status
    assert_match /must have at least one requirement/, flash[:notice]
  end

  test "retire" do
    post :retire, id: @quest
    assert_redirected_to management_quests_path
    assert_equal SpecialCode.get_code('quest_status','retired'), @quest.reload.quest_status
  end

  test "should destroy management_quest" do
    delete :destroy, id: @quest
    assert_redirected_to management_quests_path
    assert_match /cannot be edited; it is already being used/, flash[:notice]

    @quest.update_attribute :quest_status, SpecialCode.get_code('quest_status', 'design')
    assert_difference('Quest.count', -1) do
      delete :destroy, id: @quest
    end

    assert_redirected_to management_quests_path
  end
end
