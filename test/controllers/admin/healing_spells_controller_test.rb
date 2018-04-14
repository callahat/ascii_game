require 'test_helper'

class Admin::HealingSpellsControllerTest < ActionController::TestCase
  setup do
    @healing_spell = healing_spells(:heal_spell_one)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:healing_spells)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create healing_spell" do
    assert_difference('HealingSpell.count') do
      post :create, healing_spell: @healing_spell.attributes.merge(name: 'New Spell')
    end

    assert_redirected_to admin_healing_spell_path(assigns(:healing_spell))
  end

  test "should show healing_spell" do
    get :show, id: @healing_spell
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @healing_spell
    assert_response :success
  end

  test "should update healing_spell" do
    patch :update, id: @healing_spell, healing_spell: { name: 'New Name' }
    assert_redirected_to admin_healing_spell_path(assigns(:healing_spell))
  end

  test "should destroy healing_spell" do
    assert_difference('HealingSpell.count', -1) do
      delete :destroy, id: @healing_spell
    end

    assert_redirected_to admin_healing_spells_path
  end
end
