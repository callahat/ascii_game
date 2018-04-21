require 'test_helper'

class CharacterseControllerTest < ActionController::TestCase
  setup do
    @characterse = characterses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:characterses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create characterse" do
    assert_difference('Characterse.count') do
      post :create, characterse: {  }
    end

    assert_redirected_to characterse_path(assigns(:characterse))
  end

  test "should show characterse" do
    get :show, id: @characterse
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @characterse
    assert_response :success
  end

  test "should update characterse" do
    patch :update, id: @characterse, characterse: {  }
    assert_redirected_to characterse_path(assigns(:characterse))
  end

  test "should destroy characterse" do
    assert_difference('Characterse.count', -1) do
      delete :destroy, id: @characterse
    end

    assert_redirected_to characterses_path
  end
end
