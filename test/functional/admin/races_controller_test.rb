require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/races_controller'

# Re-raise errors caught by the controller.
class Admin::RacesController; def rescue_action(e) raise e end; end

class Admin::RacesControllerTest < Test::Unit::TestCase
  fixtures :admin_races

  def setup
    @controller = Admin::RacesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = races(:first).id
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

    assert_not_nil assigns(:races)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:race)
    assert assigns(:race).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:race)
  end

  def test_create
    num_races = Race.count

    post :create, :race => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_races + 1, Race.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:race)
    assert assigns(:race).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Race.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Race.find(@first_id)
    }
  end
end
