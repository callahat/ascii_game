require 'test_helper'

class Admin::WorldsControllerTest < ActionController::TestCase
  setup do
    @world = worlds(:world_one)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:worlds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create world" do
    assert_difference('World.count') do
      post :create, world: @world.attributes.merge(name: 'New World')
    end

    assert_redirected_to admin_world_path(assigns(:world))
  end

  test "should show world" do
    get :show, id: @world
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @world
    assert_response :success
  end

  test "should update world" do
    patch :update, id: @world, world: { name: 'New Name' }
    assert_redirected_to admin_world_path(assigns(:world))
  end

  # test "should destroy world" do
  #   assert_difference('World.count', -1) do
  #     delete :destroy, id: @world
  #   end
  #
  #   assert_redirected_to admin_worlds_path
  # end
end
