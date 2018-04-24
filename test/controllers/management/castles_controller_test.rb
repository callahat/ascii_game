require 'test_helper'

class Management::CastlesControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get levels" do
    get :levels
    assert_response :success
  end

  test "should new level stairs" do
    get :new
    assert_response :success
    assert_not_nil assigns(:levels)
  end

  test "should create level stairs" do
    session[:kingdom].update_attribute :gold, 0
    @level = session[:kingdom].levels.last
    post :create, level: {id: @level.id}
    assert_redirected_to new_management_castles_path
    assert_equal 'Not enough in treasury to build more stairs', flash[:notice]

    session[:kingdom].update_attribute :gold, 500
    assert_difference 'session[:kingdom].gold', -500 do
      post :create, level: {id: @level.id}
      assert Feature
                 .where(name: "\nCastle #{session[:kingdom].name}")
                 .first
                 .local_move_events
                 .where(thing_id: @level.id)
    end
  end

  test "should destroy level stairs" do
    delete :destroy, id: events(:local_move_event)
    assert_equal [], Feature
               .where(name: "\nCastle #{session[:kingdom].name}")
               .first
               .local_move_events
  end

  test "should get throne" do
    get :throne
  end

  test "throne_level" do
    get :throne_level
    assert_not_nil assigns(:levels)
    assert_template :throne
  end

  test "throne_square" do
    post :throne_square, level: {id: levels(:first_kingdom_level_one)}
    assert_not_nil assigns(:squares)
    assert_template :throne
  end

  test "set_throne" do
    session[:level_id] = levels(:first_kingdom_level_one).id
    # something already there
    post :set_throne, throne: {spot: level_maps(:test_level_map_0_0)}
    assert_equal "Invalid place for throne; something else is already there", flash[:notice]
    assert_not_nil assigns(:squares)
    assert_template :throne

    throne_feature_name = "\nThrone #{session[:kingdom].name}"

    level_maps(:test_level_map_2_0).update_attribute :feature_id, features(:empty_feature).id

    # valid spot, for placement of throne; event no longer attached to the castle
    assert_difference 'Feature.where(name: throne_feature_name).count', +1 do
      post :set_throne, throne: {spot: level_maps(:test_level_map_2_0)}
      assert_redirected_to throne_management_castles_path, flash[:notice]
    end

    # also valid spot, resets last spot
    assert_no_difference 'Feature.where(name: throne_feature_name).count' do
      post :set_throne, throne: {spot: level_maps(:test_level_map_1_2)}
      assert_redirected_to throne_management_castles_path
      assert_equal features(:empty_feature), level_maps(:test_level_map_2_0).feature
    end
  end
end
