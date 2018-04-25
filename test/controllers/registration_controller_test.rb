require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:player]
    Recaptcha.configuration.skip_verify_env.delete("test")
  end

  test "create" do
    post :create, player: {handle: 'TestNewPlayer',
                           password: '123youknowme',
                           password_confirmation: '123youk'}
    assert_response :success
    assert assigns(:player).errors.full_messages
  end


  test "create valid player" do
    post :create, player: {handle: 'TestNewPlayer',
                           email: 'newtest@example.com',
                           password: '123youknowme',
                           password_confirmation: '123youknowme'}
    assert_response :success
    assert_equal [], assigns(:player).errors.full_messages
  end
end
