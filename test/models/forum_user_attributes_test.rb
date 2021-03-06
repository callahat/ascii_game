require 'test_helper'

class ForumUserAttributesTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "forum_user_attributes" do
    Player.all.includes(:forum_user_attribute).each do |p|
      assert p.forum_attribute.mod_level
      assert p.forum_attribute.posts
    end
    
    player = Player.last.attributes.except("id")
    player[:handle] = "MostUniqueUserName12353"
    player[:password] = "blah2018"
    player[:email] = "fake@test.com"
    new_player = Player.create(player)
    assert new_player.valid?, new_player.errors.full_messages
    assert new_player.forum_attribute, "User forum attribute row not created with player creation"
    assert new_player.forum_attribute.mod_level
    assert new_player.forum_attribute.posts == 0
  end
end
