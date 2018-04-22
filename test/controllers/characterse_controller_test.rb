require 'test_helper'

class CharacterseControllerTest < ActionController::TestCase
  setup do
    @player = players(:test_player_one)
    sign_in @player
    session[:player_character] = player_characters(:pc_one)
  end

  test "show" do
    get :show
    assert_response :success
  end

  test "attack_spells" do
    get :attack_spells
    assert_response :success
    assert_not_nil assigns(:attack_spells)
  end

  test "healing_spells" do
    get :healing_spells
    assert_response :success
    assert_not_nil assigns(:healing_spells)
  end

  test "infections" do
    get :infections
    assert_response :success
    assert_not_nil assigns(:infections)
  end

  test "pc_kills" do
    get :pc_kills
    assert_response :success
    assert_not_nil assigns(:pc_kills)
  end

  test "npc_kills" do
    get :npc_kills
    assert_response :success
    assert_not_nil assigns(:npc_kills)
  end

  test "genocides" do
    get :genocides
    assert_response :success
    assert_not_nil assigns(:genocides)
  end

  test "done_quests" do
    get :done_quests
    assert_response :success
    assert_not_nil assigns(:done_quests)
  end

  test "inventory" do
    get :inventory
    assert_response :success
    assert_not_nil assigns(:pc_items)
    assert_not_nil assigns(:equip_locs)
  end

  test "equip" do
    post :equip, id: player_character_equip_locs(:one).id
    assert_response :success
    assert_not_nil assigns(:pc_items)
    assert_equal 2, assigns(:pc_items).count
  end

  test "do_equip where an item is not equipped" do
    @loc = player_character_equip_locs(:one)
    @inv = inventories(:pcinv_1)

    assert_difference 'Inventory.find(@inv.id).quantity', -1 do
      post :do_equip, id: @loc.id, iid: @inv.id
      assert_redirected_to inventory_characterse_path
      assert_equal @inv.item, @loc.reload.item
    end
  end

  test "do_equip where an item is equipped" do
    @loc = player_character_equip_locs(:two)
    @inv = inventories(:pcinv_3)
    @loc_inv = inventories(:pcinv_1)

    assert_difference 'Inventory.find(@loc_inv.id).quantity', +1 do
      assert_difference 'Inventory.find(@inv.id).quantity', -1 do
        post :do_equip, id: @loc.id, iid: @inv.id
        assert_redirected_to inventory_characterse_path
        assert_equal @inv.item, @loc.reload.item, flash.inspect
      end
    end
  end

  test "unequip" do
    @loc = player_character_equip_locs(:two)
    @loc_inv = inventories(:pcinv_1)

    assert_difference 'Inventory.find(@loc_inv.id).quantity', +1 do
      post :unequip, id: player_character_equip_locs(:two).id
      assert_redirected_to inventory_characterse_path
      assert_nil @loc.reload.item
    end
  end
end
