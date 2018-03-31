require 'test_helper'

class Admin::NameSurfixesControllerTest < ActionController::TestCase
  setup do
    @name_surfix = name_surfixes(:surfix_one)
    session[:player] = players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:name_surfixes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create name_surfix" do
    assert_difference('NameSurfix.count') do
      post :create, name_surfix: { surfix: "Mo'" }
    end

    assert_redirected_to admin_name_surfixes_path
  end

  test "should get edit" do
    get :edit, id: @name_surfix
    assert_response :success
  end

  test "should update name_surfix" do
    patch :update, id: @name_surfix, name_surfix: { surfix: "Up-" }
    assert_redirected_to admin_name_surfixes_path
  end

  test "should destroy name_surfix" do
    assert_difference('NameSurfix.count', -1) do
      delete :destroy, id: @name_surfix
    end

    assert_redirected_to admin_name_surfixes_path
  end
end
