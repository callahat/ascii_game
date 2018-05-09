require 'test_helper'

class Management::KingdomFinancesControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
  end

  test "show" do
    get :show
    assert_response :success
  end

  test "edit" do
    get :edit
    assert_response :success
  end

  test "withdraw" do
    session[:kingdom].update_attribute :gold, 0
    assert_no_difference 'session[:kingdom].reload.gold' do
      post :withdraw, withdraw: 9999999
      assert_redirected_to edit_management_kingdom_finances_path
    end

    session[:kingdom].update_attribute :gold, 500
    assert_difference 'session[:kingdom].player_character.reload.gold', +30 do
      assert_difference 'session[:kingdom].reload.gold', -30 do
        post :withdraw, withdraw: 30
        assert_redirected_to edit_management_kingdom_finances_path
      end
    end
  end

  test "deposit" do
    session[:kingdom].player_character.update_attribute :gold, 0
    assert_no_difference 'session[:kingdom].player_character.reload.gold' do
      post :deposit, deposit: 9999999
      assert_redirected_to edit_management_kingdom_finances_path
    end

    session[:kingdom].player_character.update_attribute :gold, 500
    assert_difference 'session[:kingdom].reload.gold', +30 do
      assert_difference 'session[:kingdom].player_character.reload.gold', -30 do
        post :deposit, deposit: 30
        assert_redirected_to edit_management_kingdom_finances_path
      end
    end
  end

  test "adjust_tax" do
    assert_no_difference 'session[:kingdom].reload.tax_rate' do
      post :adjust_tax, taxes: "-4"
      assert_redirected_to edit_management_kingdom_finances_path
    end

    post :adjust_tax, taxes: "10"
    assert_redirected_to edit_management_kingdom_finances_path
    assert_equal 10.0, session[:kingdom].tax_rate
  end
end
