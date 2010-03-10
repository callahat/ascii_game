require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/npcs_controller'

# Re-raise errors caught by the controller.
class Admin::NpcsController; def rescue_action(e) raise e end; end

class Admin::NpcsControllerTest < Test::Unit::TestCase
  fixtures :admin_npcs

  def setup
    @controller = Admin::NpcsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = npcs(:first).id
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

    assert_not_nil assigns(:npcs)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:npc)
    assert assigns(:npc).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:npc)
  end

  def test_create
    num_npcs = Npc.count

    post :create, :npc => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_npcs + 1, Npc.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:npc)
    assert assigns(:npc).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Npc.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Npc.find(@first_id)
    }
  end
end
