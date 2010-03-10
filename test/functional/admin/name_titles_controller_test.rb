require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/name_titles_controller'

# Re-raise errors caught by the controller.
class Admin::NameTitlesController; def rescue_action(e) raise e end; end

class Admin::NameTitlesControllerTest < Test::Unit::TestCase
  fixtures :admin_name_titles

  def setup
    @controller = Admin::NameTitlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = name_titles(:first).id
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

    assert_not_nil assigns(:name_titles)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:name_title)
    assert assigns(:name_title).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:name_title)
  end

  def test_create
    num_name_titles = NameTitle.count

    post :create, :name_title => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_name_titles + 1, NameTitle.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:name_title)
    assert assigns(:name_title).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      NameTitle.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      NameTitle.find(@first_id)
    }
  end
end
