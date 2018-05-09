require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  def setup
    @player = players(:player_with_only_old_password)
  end

  test "encrypted password is updated" do
    assert_equal '', @player.encrypted_password
    assert @player.valid_password? "thisREALbad"
    assert @player.encrypted_password
  end
end
