require 'test_helper'

class Management::KingdomNoticesControllerTest < ActionController::TestCase
  setup do
    @management_kingdom_notice = management_kingdom_notices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_kingdom_notices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_kingdom_notice" do
    assert_difference('Management::KingdomNotice.count') do
      post :create, management_kingdom_notice: {  }
    end

    assert_redirected_to management_kingdom_notice_path(assigns(:management_kingdom_notice))
  end

  test "should show management_kingdom_notice" do
    get :show, id: @management_kingdom_notice
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_kingdom_notice
    assert_response :success
  end

  test "should update management_kingdom_notice" do
    patch :update, id: @management_kingdom_notice, management_kingdom_notice: {  }
    assert_redirected_to management_kingdom_notice_path(assigns(:management_kingdom_notice))
  end

  test "should destroy management_kingdom_notice" do
    assert_difference('Management::KingdomNotice.count', -1) do
      delete :destroy, id: @management_kingdom_notice
    end

    assert_redirected_to management_kingdom_notices_path
  end
end
