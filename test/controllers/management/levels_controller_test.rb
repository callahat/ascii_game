require 'test_helper'

class Management::LevelsControllerTest < ActionController::TestCase
  def setup
    sign_in players(:test_player_one)
    session[:kingdom] = player_characters(:test_king).kingdoms.first
    
    @f_armed = features(:feature_creature_one)
    @empty = features(:empty_feature)
    @level1 = levels(:first_kingdom_level_one)
  end
  
  test "index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:levels)
  end
  
  test "show" do
    get :show, id: @level1
    assert_response :success
    assert_not_nil assigns(:level)
  end
  
  test "new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:level)
  end

  test "create" do
    session[:kingdom].update_attribute :gold, 0
    post :create, level: { level: session[:kingdom].levels.first.level - 1,maxx: 3,maxy: 3}
    assert_redirected_to new_management_level_path
    assert_match /It would cost \d+ gold/, flash[:notice]

    session[:kingdom].update_attribute :gold, 100000
    assert_difference 'LevelMap.count', +9 do
      post :create, level: { level: session[:kingdom].levels.first.level - 1,maxx: 3,maxy: 3}
      assert_redirected_to management_levels_path
    end
  end
  
  test "edit" do
    get :edit, id: @level1
    assert_response :success
    assert_not_nil assigns(:gold)
    assert_not_nil assigns(:features)
  end

  test "update" do
    session[:kingdom].update_attribute :gold, 0
    patch :update, id: @level1, map: { '0' => {'0' => @f_armed.id, '1' => '', '2' => ''},
                                       '1' => {'0' => '', '1' => @f_armed.id, '2' => ''},
                                       '2' => {'0' => '', '1' => '', '2' => ''}}
    assert_redirected_to edit_management_level_path(@level1)
    assert_match /not enough gold.*Available amount : 0 ; Total build cost : \d+/, flash[:notice]

    session[:kingdom].update_attribute :gold, 10000
    initial_gold = session[:kingdom].gold
    assert_difference 'KingdomEmptyShop.count', +1 do
      assert_difference 'session[:kingdom].reload.housing_cap', +5 do
        patch :update, id: @level1, map: { '0' => {'0' => '', '1' => @f_armed.id, '2' => ''},
                                           '1' => {'0' => '', '1' => @f_armed.id, '2' => ''},
                                           '2' => {'0' => '', '1' => '', '2' => ''}}
        assert_equal features(:kingdom_one_castle_feature),
                     @level1.level_maps.where(xpos: 1, ypos: 1).last.feature
        assert_equal features(:feature_creature_one),
                     @level1.level_maps.where(xpos: 1, ypos: 0).last.feature
      end
    end
    assert session[:kingdom].gold < initial_gold, 'Should have spent gold'

    initial_gold = session[:kingdom].gold
    assert_difference 'KingdomEmptyShop.count', -1 do
      assert_difference 'session[:kingdom].reload.housing_cap', -5 do
        patch :update, id: @level1, map: { '0' => {'0' => '', '1' => @empty.id, '2' => ''},
                                           '1' => {'0' => '', '1' => '', '2' => ''},
                                           '2' => {'0' => '', '1' => '', '2' => ''}}
        assert_equal features(:kingdom_one_castle_feature),
                     @level1.level_maps.where(xpos: 1, ypos: 1).last.feature
        assert_equal features(:empty_feature),
                     @level1.level_maps.where(xpos: 1, ypos: 0).last.feature
      end
    end
    assert session[:kingdom].gold > initial_gold
  end
end
