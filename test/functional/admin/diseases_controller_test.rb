require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/diseases_controller'

# Re-raise errors caught by the controller.
class Admin::DiseasesController; def rescue_action(e) raise e end; end

class Admin::DiseasesControllerTest < Test::Unit::TestCase
  fixtures :admin_diseases

  def setup
    @controller = Admin::DiseasesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = diseases(:first).id
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

    assert_not_nil assigns(:diseases)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:disease)
    assert assigns(:disease).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:disease)
  end

  def test_create
    num_diseases = Disease.count

    post :create, :disease => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_diseases + 1, Disease.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:disease)
    assert assigns(:disease).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Disease.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Disease.find(@first_id)
    }
  end
end
