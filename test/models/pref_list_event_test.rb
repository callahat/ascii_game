require 'test_helper'

class PrefListEventTest < ActiveSupport::TestCase
	def setup
		@kingdom = Kingdom.find_by_name("HealthyTestKingdom")
		@player_id = 1
	end

	test "pref list Event current list" do
		@list = PrefListEvent.current_list(@kingdom)
		assert @list
		assert @list.first.thing.class.base_class == Event
	end

	test "pref list Event eligible list" do
		@eligible = PrefListEvent.eligible_list(@player_id, @kingdom.id)
		assert @eligible
		assert @eligible.first.class.base_class == Event
	end
end