require 'test_helper'

class Management::KingdomEntriesControllerTest < ActionController::TestCase
  setup do
    @management_kingdom_entry = management_kingdom_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_kingdom_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_kingdom_entry" do
    assert_difference('Management::KingdomEntry.count') do
      post :create, management_kingdom_entry: {  }
    end

    assert_redirected_to management_kingdom_entry_path(assigns(:management_kingdom_entry))
  end

  test "should show management_kingdom_entry" do
    get :show, id: @management_kingdom_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_kingdom_entry
    assert_response :success
  end

  test "should update management_kingdom_entry" do
    patch :update, id: @management_kingdom_entry, management_kingdom_entry: {  }
    assert_redirected_to management_kingdom_entry_path(assigns(:management_kingdom_entry))
  end

  test "should destroy management_kingdom_entry" do
    assert_difference('Management::KingdomEntry.count', -1) do
      delete :destroy, id: @management_kingdom_entry
    end

    assert_redirected_to management_kingdom_entries_path
  end
end
