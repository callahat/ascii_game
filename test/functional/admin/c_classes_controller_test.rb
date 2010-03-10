require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/c_classes_controller'

# Re-raise errors caught by the controller.
class Admin::CClassesController; def rescue_action(e) raise e end; end

class Admin::CClassesControllerTest < Test::Unit::TestCase
  fixtures :admin_c_classes

  def setup
    @controller = Admin::CClassesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = c_classes(:first).id
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

    assert_not_nil assigns(:c_classes)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:c_class)
    assert assigns(:c_class).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:c_class)
  end

  def test_create
    num_c_classes = CClass.count

    post :create, :c_class => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_c_classes + 1, CClass.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:c_class)
    assert assigns(:c_class).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      CClass.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      CClass.find(@first_id)
    }
  end
end
