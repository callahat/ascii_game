require 'test_helper'

class Management::KingdomNoticesControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    @kingdom_notice = kingdom_notices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kingdom_notices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kingdom_notice" do
    assert_no_difference('KingdomNotice.count') do
      post :create, kingdom_notice: @kingdom_notice.attributes.merge(text: '')
    end

    assert_difference('KingdomNotice.count') do
      post :create, kingdom_notice: @kingdom_notice.attributes.merge(text: 'New Notice')
    end

    assert_redirected_to management_kingdom_notices_path
  end

  test "should get edit" do
    get :edit, id: @kingdom_notice
    assert_response :success
  end

  test "should update kingdom_notice" do
    patch :update, id: @kingdom_notice, kingdom_notice: { text: '' }
    assert_template :edit

    patch :update, id: @kingdom_notice, kingdom_notice: { text: 'Something new...' }
    assert_redirected_to management_kingdom_notices_path
  end

  test "should destroy kingdom_notice" do
    assert_difference('KingdomNotice.count', -1) do
      delete :destroy, id: @kingdom_notice
    end

    assert_redirected_to management_kingdom_notices_path
  end
end
