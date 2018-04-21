require 'test_helper'

class Management::KingdomFinancesControllerTest < ActionController::TestCase
  setup do
    @management_kingdom_finance = management_kingdom_finances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:management_kingdom_finances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create management_kingdom_finance" do
    assert_difference('Management::KingdomFinance.count') do
      post :create, management_kingdom_finance: {  }
    end

    assert_redirected_to management_kingdom_finance_path(assigns(:management_kingdom_finance))
  end

  test "should show management_kingdom_finance" do
    get :show, id: @management_kingdom_finance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @management_kingdom_finance
    assert_response :success
  end

  test "should update management_kingdom_finance" do
    patch :update, id: @management_kingdom_finance, management_kingdom_finance: {  }
    assert_redirected_to management_kingdom_finance_path(assigns(:management_kingdom_finance))
  end

  test "should destroy management_kingdom_finance" do
    assert_difference('Management::KingdomFinance.count', -1) do
      delete :destroy, id: @management_kingdom_finance
    end

    assert_redirected_to management_kingdom_finances_path
  end
end
