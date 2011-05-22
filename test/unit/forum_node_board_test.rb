require 'test_helper'

class ForumNodeBoardTest < ActiveSupport::TestCase
  def setup
    @junior_mod = players(:test_player_junior_mod)
    @banned_player = players(:banned_player)
    @non_mod = players(:test_player_one)
    
    @board1 = forum_nodes(:board_1)
    @mod_board = forum_nodes(:board_2)
  end

  # Replace this with your real tests.
  test "non mod level nine create" do
    @board = ForumNodeBoard.new(:name => "New Board Test", :text => "Just testing, board should fail")
    @board.player_id = @junior_mod.id
    
    assert ! @board.save, @board.errors.inspect + @board.inspect
    assert @board.errors.size > 0
    assert @board.errors[:player_id].first =~ /Cannot create/, @board.errors[:player_id].inspect
  end

  test "threads and aliases" do
    assert @board1.threads.size == 2
    assert @board1.forum_node_threads.size == 2
  end
  
  test "who can view board" do
    assert ForumRestriction.no_viewing(@banned_player), @banned_player.forum_restrictions
  
    assert @board1.can_be_viewed_by(@junior_mod)
    assert @board1.can_be_viewed_by(@non_mod)
    assert ! @board1.can_be_viewed_by(@banned_player)
    
    assert @mod_board.can_be_viewed_by(@junior_mod)
    assert ! @mod_board.can_be_viewed_by(@non_mod)
    assert ! @mod_board.can_be_viewed_by(@banned_player)
  end
  
  test "who can make" do
    @new_board = ForumNodeBoard.new
    assert ! @new_board.can_be_made_by(@junior_mod)
    assert ! @new_board.can_be_made_by(@non_mod)
    assert ! @new_board.can_be_made_by(@banned_player)
  end
  
  test "who can edit" do
    assert ! @board1.can_be_edited_by(@junior_mod)
    assert ! @board1.can_be_edited_by(@non_mod)
    assert ! @board1.can_be_edited_by(@banned_player)
    
    assert ! @mod_board.can_be_edited_by(@junior_mod)
    assert ! @mod_board.can_be_edited_by(@non_mod)
    assert ! @mod_board.can_be_edited_by(@banned_player)
  end
end
