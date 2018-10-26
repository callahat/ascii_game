require 'test_helper'

class ForumControllerTest < ActionController::TestCase
  test "boards" do
    get :boards
    assert_response :success

    sign_in players(:test_player_mod)
    get :boards
    assert_response :success
  end

  test "new_board" do
    sign_in players(:test_player_mod)
    get :new_board
    assert_response :success
  end

  test "create_board" do
    sign_in players(:test_player_mod)
    post :create_board, board: {name: ''}
    assert assigns(:board).errors.full_messages

    post :create_board, board: {name: 'NewTestBoard', text: 'just testing around'}
    assert_redirected_to action: :boards
    assert_equal [], assigns(:board).errors.full_messages
  end

  test "edit_board" do
    sign_in players(:test_player_mod)
    get :edit_board, forum_node_id: forum_nodes(:board_1).id
    assert_response :success
  end

  test "update_board" do
    sign_in players(:test_player_mod)
    post :update_board, forum_node_id: forum_nodes(:board_1).id, board: {name: 'NewName'}
    assert_redirected_to forums_path
  end

  test "threds" do
    sign_in players(:test_player_mod)
    get :threds, bname: forum_nodes(:board_1).name
    assert_response :success
  end

  test "view_thred" do
    sign_in players(:test_player_mod)
    get :threds, bname: forum_nodes(:board_1).name, tname: forum_nodes(:thread_1_1).name
    assert_response :success
  end

  test "view_thred when not signed in" do
    get :threds, bname: forum_nodes(:board_1).name, tname: forum_nodes(:thread_1_1).name
    assert_response :success
  end

  test "new_thred" do
    sign_in players(:test_player_mod)
    get :new_thred, bname: forum_nodes(:board_1).name
    assert_response :success
  end

  test "create_thred" do
    sign_in players(:test_player_mod)
    post :create_thred, bname: forum_nodes(:board_1).name, thred: {name:''}
    assert assigns(:thred).errors.full_messages.present?

    post :create_thred, bname: forum_nodes(:board_1).name, thred: {name:'TestThred'}
    assert_redirected_to boards_path(bname: forum_nodes(:board_1).name)
    refute assigns(:thred).errors.full_messages.present?
  end

  test "edit_thred" do
    sign_in players(:test_player_mod)
    get :edit_thred, bname: forum_nodes(:board_1).name, forum_node_id: forum_nodes(:thread_1_1).id
    assert_response :success
  end

  test "update_thred" do
    sign_in players(:test_player_mod)
    post :update_thred, bname: forum_nodes(:board_1).name,
        forum_node_id: forum_nodes(:thread_1_1).id,
        thred: {name: ''}
    assert assigns(:thred).errors.full_messages.present?

    post :update_thred, bname: forum_nodes(:board_1).name,
        forum_node_id: forum_nodes(:thread_1_1).id,
        thred: {description: 'new desc'}
    refute assigns(:thred).errors.full_messages.present?
  end

  # test "leaderboard" do
  # # TODO: implement when this exists
  # end

  test "cancel_edit" do
    sign_in players(:test_player_mod)
    get :cancel_edit, bname: forum_nodes(:board_1).name,
        tname: forum_nodes(:thread_1_1).name,
        forum_node_id: forum_nodes(:post_1_1_1).id
    assert_response :redirect
  end

  test "create_post" do
    sign_in players(:test_player_mod)
    post :create_post, bname: forum_nodes(:board_1).name,
        tname: forum_nodes(:thread_1_1).name,
        post: {text: ''}
    assert assigns(:post).errors.full_messages.present?

    post :create_post, bname: forum_nodes(:board_1).name,
         tname: forum_nodes(:thread_1_1).name,
         post: {text: 'blurt'}
    refute assigns(:post).errors.full_messages.present?
  end

  test "edit_post" do
    sign_in players(:test_player_mod)
    get :edit_post, bname: forum_nodes(:board_1).name,
        tname: forum_nodes(:thread_1_1).name,
        forum_node_id: forum_nodes(:post_1_1_1)
    assert_response :success
  end

  test "update_post" do
    sign_in players(:test_player_mod)
    post :update_post, bname: forum_nodes(:board_1).name,
         tname: forum_nodes(:thread_1_1).name,
         forum_node_id: forum_nodes(:post_1_1_1).id,
         post: {text: ''}
    assert assigns(:post).errors.full_messages.present?

    post :update_post, bname: forum_nodes(:board_1).name,
         tname: forum_nodes(:thread_1_1).name,
         forum_node_id: forum_nodes(:post_1_1_1).id,
         post: {text: 'edited text'}
    refute assigns(:post).errors.full_messages.present?
  end

  test "delete_post" do
    sign_in players(:test_player_mod)
    test_post = forum_nodes(:post_1_1_1)
    post :delete_post, bname: forum_nodes(:board_1).name,
         tname: forum_nodes(:thread_1_1).name,
         forum_node_id: test_post.id
    assert_response :redirect
    assert test_post.reload.is_deleted
  end

  test "banhammer" do
    sign_in players(:test_player_mod)
    get :banhammer, bname: forum_nodes(:board_1).name,
        tname: forum_nodes(:thread_1_1).name,
        player_id: players(:banned_player)
    assert_response :success
  end

  test "hammer_strike" do
    sign_in players(:test_player_mod)
    post :hammer_strike, bname: forum_nodes(:board_1).name,
         tname: forum_nodes(:thread_1_1).name,
         player_id: players(:banned_player),
         forum_restriction: {
            restriction: '',
            expires: 3
         }
    assert assigns(:forum_restriction).errors.full_messages.present?

    post :hammer_strike, bname: forum_nodes(:board_1).name,
         tname: forum_nodes(:thread_1_1).name,
         player_id: players(:banned_player),
         forum_restriction: {
             restriction: SPEC_CODET['restrictions'].first[1],
             expires: 4
         }
    refute assigns(:forum_restriction).errors.full_messages.present?
  end

  test "kill_ban" do
    sign_in players(:test_player_mod)
    assert_difference 'ForumRestriction.count', -1 do
      get :kill_ban, bname: forum_nodes(:board_1).name,
           tname: forum_nodes(:thread_1_1).name,
           ban_id: forum_restrictions(:one_1)
    end
  end

  test "promote_mod" do
    sign_in players(:test_player_mod)
    player = players(:test_player_junior_mod)
    get :promote_mod, bname: forum_nodes(:board_1).name,
        tname: forum_nodes(:thread_1_1).name,
        player_id: player.id
  end

  test "do_promote" do
    sign_in players(:test_player_mod)
    player = players(:test_player_junior_mod)
    post :promote_mod, bname: forum_nodes(:board_1).name,
        tname: forum_nodes(:thread_1_1).name,
        player_id: player.id, player: {mod_level: 5}
    assert 5, player.forum_user_attribute.mod_level
  end

  test "toggle_locked" do
    request.env["HTTP_REFERER"] = forums_path
    sign_in players(:test_player_mod)
    test_board = forum_nodes(:board_1)
    post :toggle_locked, forum_node_id: forum_nodes(:board_1).id
    assert_response :redirect
    assert test_board.reload.is_locked
  end

  test "toggle_hidden" do
    request.env["HTTP_REFERER"] = forums_path
    sign_in players(:test_player_mod)
    test_board = forum_nodes(:board_1)
    post :toggle_hidden, forum_node_id: forum_nodes(:board_1).id
    assert_response :redirect
    assert test_board.reload.is_hidden
  end

  test "toggle_deleted" do
    request.env["HTTP_REFERER"] = forums_path
    sign_in players(:test_player_mod)
    test_board = forum_nodes(:board_1)
    post :toggle_deleted, forum_node_id: forum_nodes(:board_1).id
    assert_response :redirect
    assert test_board.reload.is_deleted
  end

  test "toggle_mods_only" do
    request.env["HTTP_REFERER"] = forums_path
    sign_in players(:test_player_mod)
    test_board = forum_nodes(:board_1)
    post :toggle_mods_only, forum_node_id: forum_nodes(:board_1).id
    assert_response :redirect
    assert test_board.reload.is_mods_only
  end

  # test "show_restrictions" do
  # # TODO: add this once implemented
  # end
end
