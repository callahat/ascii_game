require 'test_helper'

class Admin::DiseasesControllerTest < ActionController::TestCase
  setup do
    @disease = diseases(:air_disease)
    session[:player] = players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:diseases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create disease" do
    assert_difference('Disease.count') do
      post :create, disease: @disease.attributes_with_nesteds.merge(name: 'New Disease')
    end

    assert_redirected_to admin_disease_path(assigns(:disease))
  end

  test "should show disease" do
    get :show, id: @disease
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @disease
    assert_response :success
  end

  test "should update disease" do
    patch :update, id: @disease, disease: { name: 'updated name' }
    assert_redirected_to admin_disease_path(assigns(:disease)), assigns(:disease).errors.full_messages
  end

  test "should destroy disease" do
    assert_difference('Disease.count', -1) do
      delete :destroy, id: @disease
    end

    assert_redirected_to admin_diseases_path
  end
end
