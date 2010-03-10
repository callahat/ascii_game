require 'test_helper'

class QuestTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "fixture init and all reqs" do
    assert Quest.count == 2
    assert Quest.find_by_name("Quest One").reqs.size == 6
    assert Quest.find_by_name("Quest Two").reqs.size == 2, Quest.find_by_name("Quest Two").reqs.size
  end
end
