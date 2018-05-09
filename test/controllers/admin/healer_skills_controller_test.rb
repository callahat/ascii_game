require 'test_helper'

class Admin::HealerSkillsControllerTest < ActionController::TestCase
  setup do
    @healer_skill = healer_skills(:healer_skill_one)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:healer_skills)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create healer_skill" do
    assert_difference('HealerSkill.count') do
      post :create, healer_skill: @healer_skill.attributes.merge(max_HP_restore: 10)
    end

    assert_redirected_to admin_healer_skill_path(assigns(:healer_skill))
  end

  test "should show healer_skill" do
    get :show, id: @healer_skill
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @healer_skill
    assert_response :success
  end

  test "should update healer_skill" do
    patch :update, id: @healer_skill, healer_skill: { min_sales: 4000 }
    assert_redirected_to admin_healer_skill_path(assigns(:healer_skill))
  end

  test "should destroy healer_skill" do
    assert_difference('HealerSkill.count', -1) do
      delete :destroy, id: @healer_skill
    end

    assert_redirected_to admin_healer_skills_path
  end
end
