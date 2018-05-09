require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "index" do
    get  :index
    assert_response :success

    sign_in players(:test_player_one)
    get  :index
    assert_response :success
  end
end
