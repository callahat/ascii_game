require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  test "show" do
    sign_in players(:test_player_one)
    get :show
    assert assigns(:player)
    assert_response :success
  end

  test "what" do
    get :what
    assert_response :success
  end
end
