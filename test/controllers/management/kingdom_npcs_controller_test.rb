require 'test_helper'

class Management::KingdomNpcsControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    @unhired_guard    = npcs(:unhired_guard)
    @unhired_merchant = npcs(:unhired_merchant)
    @hired_merchant   = npcs(:npc_one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:merchs)
    assert_not_nil assigns(:guards)
    assert_not_nil assigns(:npcs_for_hire)
  end

  test "should show management_kingdom_npc" do
    get :show, id: @hired_merchant
    assert_response :success
    get :show, id: @unhired_guard
    assert_response :success
    get :show, id: @unhired_merchant
    assert_response :success
  end

  test "should assign_store" do
    get :assign_store, id: @unhired_merchant
    assert_response :success
    assert_not_nil assigns(:shops)

    session[:kingdom].kingdom_empty_shops.destroy_all
    get :assign_store, id: @unhired_merchant
    assert_redirected_to management_kingdom_npcs_path
    assert_equal 'No available storefronts for the merchants.', flash[:notice]
  end

  test "hire_guard" do
    post :hire_guard, id: @unhired_guard
    assert @unhired_guard.reload.is_hired
    assert_redirected_to management_kingdom_npcs_path
  end

  test "hire_merchant - randomly assign store" do
    assert_difference 'EventNpc.count', +1 do
      post :hire_merchant, id: @unhired_merchant, level_map: { id: '' }
      assert assigns(:level_map)
      assert assigns(:level_map).feature.npc_events.map(&:npc).include?(@unhired_merchant)
      assert @unhired_merchant.reload.is_hired
      assert_redirected_to management_kingdom_npcs_path
    end
  end

  test "hire_merchant - assign store" do
    assert_difference 'EventNpc.count', +1 do
      post :hire_merchant, id: @unhired_merchant, level_map: { id: kingdom_empty_shops(:one) }
      assert assigns(:level_map)
      assert assigns(:level_map).feature.npc_events.map(&:npc).include?(@unhired_merchant)
      assert @unhired_merchant.reload.is_hired
      assert_redirected_to management_kingdom_npcs_path
    end
  end

  test "hire_merchant - invalid space picked" do
    post :hire_merchant, id: @unhired_merchant, level_map: { id: '12345' }
    assert_redirected_to management_kingdom_npcs_path
    assert_equal 'No store found for the NPC to set up shop.', flash[:notice]
  end

  test "turn_away guard" do
    @guard = npcs(:guard_1)
    # Guard
    assert_difference 'session[:kingdom].guards.count', -1 do
      post :turn_away, id: @guard
      assert_redirected_to management_kingdom_npcs_path
      assert_not @guard.reload.is_hired
      assert_nil @guard.kingdom_id
    end

    # Merchant
    shops = @hired_merchant.event_npcs.count
    assert_difference 'KingdomEmptyShop.count', +shops do
      assert_difference 'session[:kingdom].merchants.count', -1 do
        post :turn_away, id: @hired_merchant
        assert_redirected_to management_kingdom_npcs_path
        assert_not @hired_merchant.reload.is_hired
        assert_nil @hired_merchant.kingdom_id
        assert_equal 0, @hired_merchant.event_npcs.count
      end
    end
  end
end
