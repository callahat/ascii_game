require 'test_helper'

class QuestTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "fixture init and all reqs" do
    assert_equal 2, Quest.count
    assert_equal 6, Quest.find_by_name("Quest One").reqs.size
    assert_equal 2, Quest.find_by_name("Quest Two").reqs.size
  end
end
