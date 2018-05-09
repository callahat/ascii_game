require 'test_helper'

class Management::KingdomItemsControllerTest < ActionController::TestCase
  setup do
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kingdom_items)
  end

  test "should get list_inventory" do
    get :list_inventory
    assert_response :success
    assert_not_nil assigns(:player_character_items)
  end

  test "store" do
    @kings_item = inventories(:pcinv_8)
    get :store, id: @kings_item.id
    assert_response :success
    assert_not_nil assigns(:player_character_item)
  end

  test "do_store" do
    @kings_item = inventories(:pcinv_8)
    post :do_store, id: @kings_item.id, item_id: @kings_item.item_id, player_character_item: {quantity: -1}
    assert_redirected_to store_management_kingdom_items_path(id: @kings_item.id)
    assert_equal 'Number to remove must be positive', flash[:notice]

    post :do_store, id: @kings_item.id, item_id: @kings_item.item_id, player_character_item: {quantity: 100}
    assert_redirected_to store_management_kingdom_items_path(id: @kings_item)
    assert_equal "You cannot store more items than you have in the character's inventory.", flash[:notice]

    assert_difference '@kings_item.reload.quantity', -1 do
      assert_difference 'session[:kingdom].kingdom_items.where(item_id: @kings_item.item_id).count', +1 do
        post :do_store, id: @kings_item.id, item_id: @kings_item.item_id, player_character_item: {quantity: 1}
        assert_redirected_to list_inventory_management_kingdom_items_path
      end
    end
  end

  test "remove" do
    @kingdom_item = inventories(:kinv_1)
    get :remove, id: @kingdom_item.id
    assert_response :success
    assert_not_nil assigns(:kingdom_item)
  end

  test "do_take" do
    @kingdom_item = inventories(:kinv_2)
    post :do_take, id: @kingdom_item.id, item_id: @kingdom_item.item_id, kingdom_item: {quantity: -1}
    assert_redirected_to remove_management_kingdom_items_path(id: @kingdom_item.id)
    assert_equal 'Number to remove must be positive', flash[:notice]

    post :do_take, id: @kingdom_item.id, item_id: @kingdom_item.item_id, kingdom_item: {quantity: 999}
    assert_redirected_to remove_management_kingdom_items_path(id: @kingdom_item)
    assert_equal "You cannot remove more items than exist in the kingdom.", flash[:notice]

    assert_difference '@kingdom_item.reload.quantity', -1 do
      assert_difference 'session[:kingdom].player_character.items.where(item_id: @kingdom_item.item_id).count', +1 do
        post :do_take, id: @kingdom_item.id, item_id: @kingdom_item.item_id, kingdom_item: {quantity: 1}
        assert_redirected_to management_kingdom_items_path, flash[:notice]
      end
    end
  end

end
