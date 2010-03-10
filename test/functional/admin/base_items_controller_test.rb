require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/base_items_controller'

# Re-raise errors caught by the controller.
class Admin::BaseItemsController; def rescue_action(e) raise e end; end

class Admin::BaseItemsControllerTest < Test::Unit::TestCase
  fixtures :admin_base_items

  def setup
    @controller = Admin::BaseItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = base_items(:first).id
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

    assert_not_nil assigns(:base_items)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:base_item)
    assert assigns(:base_item).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:base_item)
  end

  def test_create
    num_base_items = BaseItem.count

    post :create, :base_item => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_base_items + 1, BaseItem.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:base_item)
    assert assigns(:base_item).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      BaseItem.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      BaseItem.find(@first_id)
    }
  end
end
