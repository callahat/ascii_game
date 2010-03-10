require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/healer_skills_controller'

# Re-raise errors caught by the controller.
class Admin::HealerSkillsController; def rescue_action(e) raise e end; end

class Admin::HealerSkillsControllerTest < Test::Unit::TestCase
  fixtures :admin_healer_skills

  def setup
    @controller = Admin::HealerSkillsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = healer_skills(:first).id
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

    assert_not_nil assigns(:healer_skills)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:healer_skill)
    assert assigns(:healer_skill).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:healer_skill)
  end

  def test_create
    num_healer_skills = HealerSkill.count

    post :create, :healer_skill => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_healer_skills + 1, HealerSkill.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:healer_skill)
    assert assigns(:healer_skill).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      HealerSkill.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      HealerSkill.find(@first_id)
    }
  end
end
