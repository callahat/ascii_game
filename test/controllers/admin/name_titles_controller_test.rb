require 'test_helper'

class Admin::NameTitlesControllerTest < ActionController::TestCase
  setup do
    @name_title = name_titles(:name_title_one)
    session[:player] = players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:name_titles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create name_title" do
    assert_difference('NameTitle.count') do
      post :create, name_title: { title: 'New title' }
    end

    assert_redirected_to admin_name_titles_path
  end

  test "should get edit" do
    get :edit, id: @name_title
    assert_response :success
  end

  test "should update name_title" do
    patch :update, id: @name_title, name_title: { title: 'Updated title' }
    assert_redirected_to admin_name_titles_path
  end

  test "should destroy name_title" do
    assert_difference('NameTitle.count', -1) do
      delete :destroy, id: @name_title
    end

    assert_redirected_to admin_name_titles_path
  end
end
