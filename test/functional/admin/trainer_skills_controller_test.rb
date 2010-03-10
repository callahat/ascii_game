require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/trainer_skills_controller'

# Re-raise errors caught by the controller.
class Admin::TrainerSkillsController; def rescue_action(e) raise e end; end

class Admin::TrainerSkillsControllerTest < Test::Unit::TestCase
  fixtures :admin_trainer_skills

  def setup
    @controller = Admin::TrainerSkillsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = trainer_skills(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:trainer_skills)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:trainer_skill)
    assert assigns(:trainer_skill).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:trainer_skill)
  end

  def test_create
    num_trainer_skills = TrainerSkill.count

    post :create, :trainer_skill => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_trainer_skills + 1, TrainerSkill.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:trainer_skill)
    assert assigns(:trainer_skill).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      TrainerSkill.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      TrainerSkill.find(@first_id)
    }
  end
end
