require 'test_helper'

class Admin::WorldMapsControllerTest < ActionController::TestCase
  setup do
    @world = worlds(:world_one)
    @bigxpos, @bigypos = 0, 0
    sign_in players(:test_system_player)
    # kingdom_id -1 is hardcoded system placeholder kingdom
    kingdom = Kingdom.new name: 'Generated',
        player_character_id: players(:test_system_player).id,
        world_id: @world.id,
        bigx: 0, bigy: 0, num_peasants: 0
    kingdom.id = -1
    kingdom.save!
  end

  test "should get index" do
    get :index, world_id: @world.id
    assert_response :success
    assert_not_nil assigns(:world)
  end

  test "should get new" do
    get :new, world_id: @world.id
    assert_response :success
  end

  test "should create world_map" do
    assert_difference('WorldMap.count',+36) do
      post :create, world_id: @world.id, map: { loc: '0,1' }
    end

    assert_redirected_to admin_world_maps_path(assigns(:world))
  end

  test "should show world_map" do
    get :show, {world_id: @world, id: "#{@bigxpos}x#{@bigypos}"}
    assert_response :success
  end

  test "should get edit" do
    get :edit, world_id: @world, id: "#{@bigxpos}x#{@bigypos}"
    assert_response :success
  end

  test "should update admin_world_map" do
    map_hash = (1..6).inject({}) do |x_hash, x|
      x_hash.merge("#{x}" => (1..6).inject({}) do |y_hash, y|
        y_hash.merge("#{y}" => "")
      end)
    end
    map_hash['1']['2'] = Feature.first.id

    patch :update, world_id: @world, id: "#{@bigxpos}x#{@bigypos}", map: map_hash
    assert_redirected_to admin_world_map_path(world_id: assigns(:world), id: "#{@bigxpos}x#{@bigypos}")
  end

  # test "should destroy admin_world_map" do
  #   assert_difference('Admin::WorldMap.count', -1) do
  #     delete :destroy, id: @admin_world_map
  #   end
  #
  #   assert_redirected_to admin_world_maps_path
  # end
end
