require 'test_helper'

class Admin::AttackSpellsControllerTest < ActionController::TestCase
  setup do
    @attack_spell = attack_spells(:weak_attack_spell)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:attack_spells)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create attack_spell" do
    assert_difference('AttackSpell.count') do
      post :create, attack_spell: @attack_spell.attributes.merge(name: 'New Attack Spell')
    end

    assert_redirected_to admin_attack_spell_path(assigns(:attack_spell))
  end

  test "should show attack_spell" do
    get :show, id: @attack_spell
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @attack_spell
    assert_response :success
  end

  test "should update attack_spell" do
    patch :update, id: @attack_spell, attack_spell: { name: 'New Name' }
    assert_redirected_to admin_attack_spell_path(assigns(:attack_spell))
  end

  test "should destroy admin_attack_spell" do
    assert_difference('AttackSpell.count', -1) do
      delete :destroy, id: @attack_spell
    end

    assert_redirected_to admin_attack_spells_path
  end
end
