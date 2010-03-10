require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/worlds_controller'

# Re-raise errors caught by the controller.
class Admin::WorldsController; def rescue_action(e) raise e end; end

class Admin::WorldsControllerTest < Test::Unit::TestCase
  fixtures :admin_worlds

  def setup
    @controller = Admin::WorldsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = worlds(:first).id
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

    assert_not_nil assigns(:worlds)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:world)
    assert assigns(:world).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:world)
  end

  def test_create
    num_worlds = World.count

    post :create, :world => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_worlds + 1, World.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:world)
    assert assigns(:world).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      World.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      World.find(@first_id)
    }
  end
end
