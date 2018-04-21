require 'test_helper'

class Management::CastlesControllerTest < ActionController::TestCase
  setup do
    @management_castle = management_castles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_castles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_castle" do
    assert_difference('Management::Castle.count') do
      post :create, management_castle: {  }
    end

    assert_redirected_to management_castle_path(assigns(:management_castle))
  end

  test "should show management_castle" do
    get :show, id: @management_castle
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_castle
    assert_response :success
  end

  test "should update management_castle" do
    patch :update, id: @management_castle, management_castle: {  }
    assert_redirected_to management_castle_path(assigns(:management_castle))
  end

  test "should destroy management_castle" do
    assert_difference('Management::Castle.count', -1) do
      delete :destroy, id: @management_castle
    end

    assert_redirected_to management_castles_path
  end
end
