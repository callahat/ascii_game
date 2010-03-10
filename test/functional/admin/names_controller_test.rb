require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/names_controller'

# Re-raise errors caught by the controller.
class Admin::NamesController; def rescue_action(e) raise e end; end

class Admin::NamesControllerTest < Test::Unit::TestCase
  fixtures :admin_names

  def setup
    @controller = Admin::NamesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = names(:first).id
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

    assert_not_nil assigns(:names)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:name)
    assert assigns(:name).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:name)
  end

  def test_create
    num_names = Name.count

    post :create, :name => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_names + 1, Name.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:name)
    assert assigns(:name).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Name.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Name.find(@first_id)
    }
  end
end
