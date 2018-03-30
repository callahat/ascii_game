require 'test_helper'

class Admin::BaseItemsControllerTest < ActionController::TestCase
  setup do
    @base_item = base_items(:base_item_one)
    session[:player] = players(:test_system_player)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:base_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_base_item" do
    assert_difference('BaseItem.count') do
      post :create, base_item: @base_item.attributes.merge(name: 'New Base Item')
    end

    assert_redirected_to admin_base_item_path(assigns(:base_item))
  end

  test "should show base_item" do
    get :show, id: @base_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @base_item
    assert_response :success
  end

  test "should update admin_base_item" do
    patch :update, id: @base_item, base_item: { name: 'Updated Name' }
    assert_redirected_to admin_base_item_path(assigns(:base_item))
  end

  test "should destroy admin_base_item" do
    assert_difference('BaseItem.count', -1) do
      delete :destroy, id: @base_item
    end

    assert_redirected_to admin_base_items_path
  end
end
