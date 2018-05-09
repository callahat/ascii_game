require 'test_helper'

class Admin::TrainerSkillsControllerTest < ActionController::TestCase
  setup do
    @trainer_skill = trainer_skills(:trainer_skill_one)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trainer_skills)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trainer_skill" do
    assert_difference('TrainerSkill.count') do
      post :create, trainer_skill: @trainer_skill.attributes.merge(min_sales: 100)
    end

    assert_redirected_to admin_trainer_skills_path
  end

  test "should get edit" do
    get :edit, id: @trainer_skill
    assert_response :success
  end

  test "should update trainer_skill" do
    patch :update, id: @trainer_skill, trainer_skill: { min_sales: 10000 }
    assert_redirected_to admin_trainer_skills_path
  end

  test "should destroy trainer_skill" do
    assert_difference('TrainerSkill.count', -1) do
      delete :destroy, id: @trainer_skill
    end

    assert_redirected_to admin_trainer_skills_path
  end
end
