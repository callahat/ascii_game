require 'test_helper'

class ForumNodePostTest < ActiveSupport::TestCase
  def setup 
    @player_one = players(:test_player_one)
    @mod_one = players(:test_player_mod)
    @banned_player = players(:banned_player)
    
    @board1 = forum_nodes(:board_1)
    @mod_board = forum_nodes(:board_2)
    
    @thred = forum_nodes(:thread_1_1)
    @locked_thred = forum_nodes(:thread_1_2)
  end
  
  test "post create" do
    @new_post = @thred.posts.new(:name => "New Post Test1", :text => "Just testing, post should be ok")
    @new_post.player_id = @player_one.id
    
    assert @new_post.save, @new_post.errors.inspect + @new_post.inspect
  end
  
  test "post failed create" do
    @new_post = @thred.posts.new(:name => "New Thred Test", :text => "Just testing, thred should be ok")
    @new_post.player_id = @banned_player.id
    
    assert !@new_post.save, @new_post.errors.inspect + @new_post.inspect
    assert @new_post.errors.size > 0
    assert @new_post.errors[:player_id].first =~ /Cannot create/, @new_post.errors[:player_id].inspect
    
    @new_post = @locked_thred.posts.new(:name => "New Post Test2", :text => "Just testing, post should not be ok")
    @new_post.player_id = @player_one.id
    
    assert !@new_post.save, @new_post.errors.inspect + @new_post.inspect
  end
  
  test "post create in mod board" do
    @new_post = @mod_board.threads.first.posts.new(:name => "New Post Test", :text => "Just testing, post should not be ok")
    @new_post.player_id = @player_one.id
    
    assert !@new_post.save, @new_post.errors.inspect + @new_post.inspect
    assert @new_post.errors.size > 0
    assert @new_post.errors[:player_id].first =~ /Cannot create/, @new_post.errors[:player_id].inspect
    
    @new_post = @mod_board.threads.first.posts.new(:name => "New Post Test", :text => "Just testing, post should not be ok")
    @new_post.player_id = @mod_one.id
    
    assert @new_post.save, @new_post.errors.inspect + @new_post.inspect
  end

  test "post and aliases" do
    assert @thred.posts.first.thread.class == ForumNodeThread
    assert @thred.posts.first.board.class == ForumNodeBoard
  end
  
  test "who can view post" do
    @post_in_mod_board = forum_nodes(:board_2).threads.first.posts.first
    @post_in_locked_thred = @locked_thred.posts.first
    @post_deleted = forum_nodes(:post_1_1_6)
    @post_hidden = forum_nodes(:post_1_1_5)
    
    @junior_mod = players(:test_player_junior_mod)
  
    assert ! @post_in_mod_board.can_be_viewed_by(nil), @post_in_mod_board.thread.board.inspect
    assert @post_in_locked_thred.can_be_viewed_by(nil)
    assert ! @post_deleted.can_be_viewed_by(nil)
    assert ! @post_hidden.can_be_viewed_by(nil)
  
    assert ! @post_in_mod_board.can_be_viewed_by(@player_one)
    assert @post_in_locked_thred.can_be_viewed_by(@player_one)
    assert ! @post_deleted.can_be_viewed_by(@player_one)
    assert ! @post_hidden.can_be_viewed_by(@player_one)
    
    assert ! @post_in_mod_board.can_be_viewed_by(@banned_player)
    assert ! @post_in_locked_thred.can_be_viewed_by(@banned_player)
    assert ! @post_deleted.can_be_viewed_by(@banned_player)
    assert ! @post_hidden.can_be_viewed_by(@banned_player)
    
    assert @post_in_mod_board.can_be_viewed_by(@junior_mod)
    assert @post_in_locked_thred.can_be_viewed_by(@junior_mod)
    assert ! @post_deleted.can_be_viewed_by(@junior_mod)
    assert @post_hidden.can_be_viewed_by(@junior_mod)
  end
  
  test "who can edit" do
    @post = forum_nodes(:post_1_1_1)
    @post2 = forum_nodes(:post_1_2_1)
  
    assert @post.can_be_edited_by(@player_one)
    assert @post.can_be_edited_by(@mod_one)
    assert ! @post.can_be_edited_by(@banned_player)
    
    assert ! @post2.can_be_edited_by(@player_one)
    assert @post2.can_be_edited_by(@mod_one)
    assert ! @post2.can_be_edited_by(@banned_player)
  end
  
  test "last posted child" do
    @thread = @board1.threads.first
    @thread1 = forum_nodes(:thread_1_1)
    @thread2 = forum_nodes(:thread_1_2)
    
    assert_difference '@thred.board.post_count', +2 do 
      assert_difference '@thred.post_count', +1 do
        @np = @thred.posts.new(:text => "test 1 new")

        @np.player_id = @player_one.id
        
        assert @np.save, @np.errors.full_messages.inspect
        @thred.reload
        assert @thred.last_post_id == @np.id, "Thred last post id:" + @thred.last_post_id.to_s + " " + "post id:" + @np.id.to_s
        assert @thred.board.last_post_id == @thred.last_post_id, @thred.last_post_id.to_s + " " + @thred.board.last_post_id.to_s
      end
      assert_difference '@locked_thred.post_count', +1 do  
        @np2 = @locked_thred.posts.new(:text => "test 2 new")
        
        @np2.player_id = @mod_one.id
        
        assert @np2.save, @np2.errors.full_messages.inspect
        @locked_thred.reload
        assert @locked_thred.last_post_id == @np2.id, "Thred id:" + @thred.last_post_id.to_s + " " + "post id:" + @np2.id.to_s
        assert @locked_thred.board.last_post_id == @locked_thred.last_post_id,
           "#{@thred.last_post_id} #{@locked_thred.board.last_post_id}"
      end
      @thred.board.reload
    end 
  end
end
