require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/attack_spells_controller'

# Re-raise errors caught by the controller.
class Admin::AttackSpellsController; def rescue_action(e) raise e end; end

class Admin::AttackSpellsControllerTest < Test::Unit::TestCase
  fixtures :admin_attack_spells

  def setup
    @controller = Admin::AttackSpellsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = attack_spells(:first).id
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

    assert_not_nil assigns(:attack_spells)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:attack_spells)
    assert assigns(:attack_spells).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:attack_spells)
  end

  def test_create
    num_attack_spells = AttackSpells.count

    post :create, :attack_spells => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_attack_spells + 1, AttackSpells.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:attack_spells)
    assert assigns(:attack_spells).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      AttackSpells.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      AttackSpells.find(@first_id)
    }
  end
end
