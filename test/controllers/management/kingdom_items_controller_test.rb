require 'test_helper'

class Management::KingdomItemsControllerTest < ActionController::TestCase
  setup do
    @management_kingdom_item = management_kingdom_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_kingdom_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_kingdom_item" do
    assert_difference('Management::KingdomItem.count') do
      post :create, management_kingdom_item: {  }
    end

    assert_redirected_to management_kingdom_item_path(assigns(:management_kingdom_item))
  end

  test "should show management_kingdom_item" do
    get :show, id: @management_kingdom_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_kingdom_item
    assert_response :success
  end

  test "should update management_kingdom_item" do
    patch :update, id: @management_kingdom_item, management_kingdom_item: {  }
    assert_redirected_to management_kingdom_item_path(assigns(:management_kingdom_item))
  end

  test "should destroy management_kingdom_item" do
    assert_difference('Management::KingdomItem.count', -1) do
      delete :destroy, id: @management_kingdom_item
    end

    assert_redirected_to management_kingdom_items_path
  end
end
