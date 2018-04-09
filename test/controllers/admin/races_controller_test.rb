require 'test_helper'

class Admin::RacesControllerTest < ActionController::TestCase
  setup do
    @race = races(:race_two)
    session[:player] = players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:races)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create race" do
    assert_difference('Race.count') do
      post :create, race: @race.attributes_with_nesteds.merge(name: 'New Class')
      assert_equal 0, assigns(:race).errors.count, assigns(:race).errors.full_messages
    end

    assert assigns(:race).level_zero
    assert assigns(:race).race_equip_locs
    assert assigns(:race).image
    assert_redirected_to admin_race_path(assigns(:race))
  end

  test "should show race" do
    get :show, id: @race
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @race
    assert_response :success
  end

  test "should update race" do
    patch :update, id: @race, race: @race.attributes_with_nesteds.merge(name: 'updated_name')
    assert_redirected_to admin_race_path(assigns(:race)), assigns(:race).errors.full_messages
  end

  test "should destroy race" do
    assert_difference('Race.count', -1) do
      delete :destroy, id: @race
    end

    assert_redirected_to admin_races_path
  end
end
