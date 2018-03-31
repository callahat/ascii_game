require 'test_helper'

class Admin::BlacksmithSkillsControllerTest < ActionController::TestCase
  setup do
    @blacksmith_skill = blacksmith_skills(:blacksmith_skill_initial1)
    session[:player] = players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:blacksmith_skills)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_blacksmith_skill" do
    assert_difference('BlacksmithSkill.count') do
      post :create, blacksmith_skill: @blacksmith_skill.attributes.merge(min_sales: 5)
    end

    assert_redirected_to admin_blacksmith_skill_path(assigns(:blacksmith_skill))
  end

  test "should show admin_blacksmith_skill" do
    get :show, id: @blacksmith_skill
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @blacksmith_skill
    assert_response :success
  end

  test "should update admin_blacksmith_skill" do
    patch :update, id: @blacksmith_skill, blacksmith_skill: {min_sales: 9}
    assert_redirected_to admin_blacksmith_skill_path(assigns(:blacksmith_skill))
  end

  test "should destroy admin_blacksmith_skill" do
    assert_difference('BlacksmithSkill.count', -1) do
      delete :destroy, id: @blacksmith_skill
    end

    assert_redirected_to admin_blacksmith_skills_path
  end
end
