require 'test_helper'

class CharacterControllerTest < ActionController::TestCase
  setup do
    @player = players(:test_player_one)
    sign_in @player
    @pc = player_characters(:pc_one)
    @kingdom = kingdoms(:kingdom_one)
  end

  test "should get menu" do
    get :menu
    assert_response :success
    assert assigns(:player_characters)
    assert assigns(:active_chars)
  end

  test "do_choose invalid character" do
    post :do_choose, id: player_characters(:test_hollow_pc).id
    assert redirected_to: menu_character_path
    assert_equal 'Unable to load character', flash[:notice]

    post :do_choose, id: @pc.id
    assert redirected_to: main_game_path
    assert_equal player_characters(:pc_one), session[:player_character]
  end

  test "do_image_update" do
    get :do_image_update, id: @pc.id
    assert_response :success
    assert assigns(:image)
  end

  test "updateimage with image zero" do
    @pc.update_attribute :image_id, 0
    assert_raise do
      post :updateimage, id: @pc.id, image: {image_text: ':{'}
    end
  end

  test "updateimage" do
    post :updateimage, id: @pc.id, image: {image_text: ':{'}
    assert redirected_to: menu_character_path
    assert_equal 'Updated character image.', flash[:notice]
  end

  test "new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:c_classes)
    assert_not_nil assigns(:races)
  end

  test "namenew" do
    @race = Race.first
    @c_class = CClass.first

    post :namenew, race_id: @race.id, c_class_id: @c_class.id
    assert redirected_to: character_path
    assert_equal 'Character being created expired. Please try again', flash[:notice]

    session[:nplayer_character] = PlayerCharacter.new
    post :namenew, race_id: @race.id, c_class_id: @c_class.id
    assert_response :success
    assert_equal @race.id, session[:nplayer_character][:race_id]
    assert_equal @c_class.id, session[:nplayer_character][:c_class_id]
  end

  test "create" do
    @race = Race.first
    @c_class = CClass.first
    pc_hash = {player_character: {} }

    post :create, player_character: {name: 'Test', image_text: ":O", kingdom_id: @kingdom.id}
    assert redirected_to: character_path
    assert_equal 'Character being created expired. Please try again', flash[:notice]

    session[:nplayer_character] = PlayerCharacter.new
    session[:nplayer_character][:race_id] = @race.id
    session[:nplayer_character][:c_class_id] = @c_class.id

    post :create, player_character: {name: '', image_text: ":O", kingdom_id: @kingdom.id}
    assert_response :success
    assert_not_nil assigns(:player_character).errors

    post :create, player_character: {name: 'TestChar', image_text: ":O", kingdom_id: @kingdom.id}
    assert_redirected_to menu_character_path
    assert assigns(:player_character).image
    assert assigns(:player_character).race
    assert assigns(:player_character).c_class
  end

  test "raise_level when no freepoints" do
    @pc.update_attribute :freepts, 0
    session[:player_character] = @pc

    get :raise_level
    assert_redirected_to main_game_path
    assert_equal "Your power grows!", flash[:notice]
  end

  test "raise_level when freepoints" do
    @pc.update_attribute :freepts, 10
    session[:player_character] = @pc

    get :raise_level
    assert assigns(:base_stats)
    assert assigns(:distributed_freepts)
  end

  test "gainlevel" do
    @pc.update_attribute :freepts, 10
    session[:player_character] = @pc

    assert_no_difference '@pc.level' do
      post :gainlevel, distributed_freepts: {str: 999, dex: 0, con: 0, int: 0, mag: 0, dfn: 0, dam: 0}
      assert_response :success
      assert_equal 'Invalid distribution', assigns(:message)
    end

    @pc.update_attribute :experience, 0
    @pc.update_attribute :next_level_at, 50
    session[:player_character] = @pc
    assert_no_difference '@pc.level' do
      post :gainlevel, distributed_freepts: {str: 5, dex: 0, con: 0, int: 0, mag: 0, dfn: 0, dam: 0}
      assert_response :redirect
      assert_equal 'Not enough experience to gain level.', assigns(:message)
    end

    @pc.update_attribute :experience, 60
    session[:player_character] = @pc
    assert_difference '@pc.level', +1 do
      post :gainlevel, distributed_freepts: {str: 5, dex: 0, con: 0, int: 0, mag: 0, dfn: 0, dam: 0}
      assert_redirected_to main_game_path, assigns(:message)
    end
  end

  test "do_destroy" do
    session[:player_character] = @pc
    post :do_destroy, id: @pc.id
    assert_redirected_to menu_character_path
    assert_nil session[:player_character]
  end

  # test "final_death" do
  #   # TODO: add this later
  # end

  test "do_retire and unretire" do
    session[:player_character] = @pc
    post :do_retire, id: @pc.id
    assert_nil session[:player_character]
    assert_redirected_to menu_character_path
    assert_equal SpecialCode.get_code("char_stat","retired"), @pc.reload.char_stat


    post :do_unretire, id: @pc.id
    assert_redirected_to menu_character_path
    assert_equal 'Cannot have more than three active characters.', flash[:notice]
    assert SpecialCode.get_code("char_stat","retired"), @pc.reload.char_stat

    @player.player_characters.each do |pc|
      pc.update_attribute :char_stat, SpecialCode.get_code("char_stat","retired")
    end

    post :do_unretire, id: @pc.id
    assert_redirected_to menu_character_path
    assert_equal "Character \"pc one\" has been brought back from retirement.", flash[:notice]
    assert_not_equal SpecialCode.get_code("char_stat","retired"), @pc.reload.char_stat
  end
end
