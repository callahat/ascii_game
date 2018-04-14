require 'test_helper'

class Admin::CClassesControllerTest < ActionController::TestCase
  setup do
    @c_class = c_classes(:c_class_one)
    sign_in players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:c_classes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create c_class" do
    assert_difference('CClass.count') do
      post :create, c_class: @c_class.attributes_with_nesteds.merge(name: 'New Class')
    end

    assert assigns(:c_class).level_zero
    assert_redirected_to admin_c_class_path(assigns(:c_class))
  end

  test "should show c_class" do
    get :show, id: @c_class
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @c_class
    assert_response :success
  end

  test "should update c_class" do
    patch :update, id: @c_class, c_class: { name: 'New Name' }
    assert assigns(:c_class).level_zero
    assert_redirected_to admin_c_class_path(assigns(:c_class))
  end

  test "should destroy c_class" do
    assert_difference('CClass.count', -1) do
      delete :destroy, id: @c_class
    end

    assert_redirected_to admin_c_classes_path
  end
end
