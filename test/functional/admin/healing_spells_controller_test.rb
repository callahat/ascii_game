require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/healing_spells_controller'

# Re-raise errors caught by the controller.
class Admin::HealingSpellsController; def rescue_action(e) raise e end; end

class Admin::HealingSpellsControllerTest < Test::Unit::TestCase
  fixtures :admin_healing_spells

  def setup
    @controller = Admin::HealingSpellsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = healing_spells(:first).id
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

    assert_not_nil assigns(:healing_spells)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:healing_spell)
    assert assigns(:healing_spell).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:healing_spell)
  end

  def test_create
    num_healing_spells = HealingSpell.count

    post :create, :healing_spell => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_healing_spells + 1, HealingSpell.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:healing_spell)
    assert assigns(:healing_spell).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      HealingSpell.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      HealingSpell.find(@first_id)
    }
  end
end
