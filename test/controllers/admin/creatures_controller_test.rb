require 'test_helper'

class Admin::CreaturesControllerTest < ActionController::TestCase
  setup do
    @creature = creatures(:unarmed_monster)
    session[:player] = players(:test_system_player)
    @s_hash = {:dam => 10, :dex => 5, :dfn => 5, :con => 5, :int => 5, :mag => 10, :str => 30}
    @i_hash = {:image_text => "   -_o     ", :image_type => SpecialCode.get_code('image_type','creature') }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:creatures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create creature" do
    assert_difference('Creature.count') do
      post :create, creature: @creature.attributes_with_nesteds.merge(name: 'New monster', image_id: nil, image_attributes: @i_hash, stat_attributes: @s_hash )
    end

    assert_redirected_to admin_creature_path(assigns(:creature))
  end

  test "should show creature" do
    get :show, id: @creature
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @creature
    assert_response :success
  end

  test "should update creature" do
    patch :update, id: @creature, creature: @creature.attributes.merge(name: 'New Name', image_id: nil, image_attributes: @i_hash, stat_attributes: @s_hash )
    assert_redirected_to admin_creature_path(assigns(:creature))
  end

  test "should destroy creature" do
    assert_difference('Creature.count', -1) do
      delete :destroy, id: @creature
    end

    assert_redirected_to admin_creatures_path
  end

  test "should arm creature" do
    post :arm, id: @creature
    assert_redirected_to admin_creatures_path
    assert @creature.reload.armed, "Creature is not armed"
  end
end
