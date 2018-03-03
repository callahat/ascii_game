require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  test "account controller new" do
    get 'new'
    assert_response :success
  end
end
