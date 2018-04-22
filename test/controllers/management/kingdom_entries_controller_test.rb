require 'test_helper'

class Management::KingdomEntriesControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    @kingdom_ban = kingdom_bans(:one)
  end

  test "should show management_kingdom_entry" do
    get :show
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should update management_kingdom_entry" do
    assert_not_equal SpecialCode.get_code('entry_limitations','allies'), session[:kingdom].kingdom_entry
    patch :update, kingdom_entry: { allowed_entry: SpecialCode.get_code('entry_limitations','allies') }
    assert_redirected_to management_kingdom_entries_path(assigns(:management_kingdom_entry))
    assert_equal SpecialCode.get_code('entry_limitations','allies'), session[:kingdom].kingdom_entry.allowed_entry
  end
end
