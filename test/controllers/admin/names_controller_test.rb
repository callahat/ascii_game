require 'test_helper'

class Admin::NamesControllerTest < ActionController::TestCase
  setup do
    @name = names(:name_one)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:names)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create name" do
    assert_difference('Name.count') do
      post :create, name: { name: 'New name' }
    end

    assert_redirected_to admin_names_path
  end

  test "should get edit" do
    get :edit, id: @name
    assert_response :success
  end

  test "should update name" do
    patch :update, id: @name, name: { name: 'updated name' }
    assert_redirected_to admin_names_path
  end

  test "should destroy name" do
    assert_difference('Name.count', -1) do
      delete :destroy, id: @name
    end

    assert_redirected_to admin_names_path
  end
end
