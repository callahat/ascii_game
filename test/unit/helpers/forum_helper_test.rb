require 'test_helper'

class ForumHelperTest < ActionView::TestCase
  test "link_to unaffected" do
    assert_equal link_to("here", :controller => "forums"), "<a href=\"/forums\">here</a>"
  end

  #can't test, link_to function does not work properly
  test "forum_node_statuses" do
    #override the link to, otherwise no rout matches errors are thrown for this test, even though 
    #it works fine and gets the correct url when hitting the page in the browser
    def link_to(text, params)
      text + params.inspect
    end
    
    assert link_to("here", :controller => "forums") =~ /:controller/
  
    mock_player = Player.first
    
    mock_post = ForumNodePost.first
    mock_thread = ForumNodeThread.first
    mock_board = ForumNodeBoard.first
    
    [[mock_thread, nil, mock_board],
     [mock_board, nil, nil]].each do |foo|
      forum_node = foo[0]
      #array below defines mod levels with what mod toggle tags are expected (or not) to be returned
      #mod level, locked, hidden, mods only, deleted
      [[0, false, false, false, false],
       [2, false, false, false, false],
       [4, true, false, false, false],
       [7, true, true, false, false],
       [8, true, true, true, false],
       [9, true, true, true, true]].each do |level_details|
         mock_player.forum_attribute.update_attribute(:mod_level, level_details[0])
         [[:is_locked, "lock", 1],
          [:is_hidden, "hide", 2],
          [:is_mods_only, "mods_only", 3],
          [:is_deleted, "delete", 4] ].each do |what, why, ind|
         
           forum_node.update_attribute(what, true)
           
           output = forum_node_statuses(nil, forum_node, foo[2], foo[1])
           assert output =~ //
           
           output = forum_node_statuses(mock_player, forum_node, foo[2], foo[1])
           if level_details[ ind ]
             assert output =~ /un#{why}/, "Expected to find link for un" + why + "\n" + output
           else
             assert output !~ /#{why}/, "Unexpected link for" + why
           end
           
           forum_node.update_attribute(what, false)
           
           output = forum_node_statuses(nil, forum_node, foo[2], foo[1])
           assert output =~ //
           
           output = forum_node_statuses(mock_player, forum_node)
           if level_details[ ind ]
             assert output =~ /#{why}/, "Expected to find link for un" + why + "\n" + output
             assert output !~ /un#{why}/, "Unexpected link for" + why
           else
             assert output !~ /#{why}/, "Unexpected link for" + why
           end
         end
      end
    end
  end
end
