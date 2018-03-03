require 'test_helper'

class ForumNodeThreadTest < ActiveSupport::TestCase
  def setup 
    @player_one = players(:test_player_one)
    @mod_one = players(:test_player_mod)
    @banned_player = players(:banned_player)
    
    @board1 = forum_nodes(:board_1)
    @mod_board = forum_nodes(:board_2)
    
    @thred = forum_nodes(:thread_1_1)
    @locked_thred = forum_nodes(:thread_1_2)
  end
  
  test "thred create" do
    @new_thred = @board1.threads.new(:name => "New Thred Test", :text => "Just testing, thred should be ok")
    @new_thred.player_id = @player_one.id
    
    assert @new_thred.save, @new_thred.errors.inspect + @new_thred.inspect
  end
  
  test "thred failed create" do
    @new_thred = @board1.threads.new(:name => "New Thred Test", :text => "Just testing, thred should be ok")
    @new_thred.player_id = @banned_player.id
    
    assert !@new_thred.save, @new_thred.errors.inspect + @new_thred.inspect
    assert @new_thred.errors.size > 0
    assert @new_thred.errors[:player_id].first =~ /Cannot create/, @new_thred.errors[:player_id].inspect
  end
  
  test "thread fail to create in mod board" do
    @new_thred = @mod_board.threads.new(:name => "New Thred Test", :text => "Just testing, thred should be ok")
    @new_thred.player_id = @player_one.id
    
    assert !@new_thred.save, @new_thred.errors.inspect + @new_thred.inspect
    assert @new_thred.errors.size > 0
    assert @new_thred.errors[:player_id].first =~ /Cannot create/, @new_thred.errors[:player_id].inspect
  end

  test "threads and aliases" do
    assert @thred.posts.size == 6
    assert @thred.forum_node_posts.size == 6
    assert @thred.childs.size == 6
  end
  
  test "who can view board" do
    assert @thred.can_be_viewed_by(@player_one)
    assert @thred.can_be_viewed_by(nil)
    assert ! @thred.can_be_viewed_by(@banned_player)
    
    assert @locked_thred.can_be_viewed_by(@mod_one)
    assert @locked_thred.can_be_viewed_by(@player_one)
    assert ! @locked_thred.can_be_viewed_by(@banned_player)
  end
  
  test "who can make" do
    @new_thred = ForumNodeThread.new
    
    assert @new_thred.can_be_made_by(@player_one)
    assert ! @new_thred.can_be_made_by(@banned_player)
  end
  
  test "who can edit" do
    assert ! @thred.can_be_edited_by(@player_one)
    assert @thred.can_be_edited_by(@mod_one)
    assert ! @thred.can_be_edited_by(@banned_player)
    
    assert @locked_thred.can_be_edited_by(@mod_one)
    assert ! @locked_thred.can_be_edited_by(@player_one)
    assert ! @locked_thred.can_be_edited_by(@banned_player)
  end
end
