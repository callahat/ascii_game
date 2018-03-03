require 'test_helper'

class ForumUserAttributesTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "forum_user_attributes" do
    Player.all.each do |p|
      assert p.forum_attribute.mod_level
      assert p.forum_attribute.posts
    end
    
    player = Player.last.attributes
    player[:handle] = "MostUniqueUserName12353"
    player[:passwd] = "blah"
    new_player = Player.create(player)
    assert new_player.forum_attribute, "User forum attribute row not created with player creation"
    assert new_player.forum_attribute.mod_level
    assert new_player.forum_attribute.posts == 0
  end
end
