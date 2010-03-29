require 'test_helper'

class PrefListFeatureTest < ActiveSupport::TestCase
	def setup
		@kingdom = Kingdom.find_by_name("HealthyTestKingdom")
		@player_id = 1
	end

	test "pref list Feature current list" do
		@list = PrefListFeature.current_list(@kingdom)
		assert @list
		assert @list.first.thing.class == Feature
	end

	test "pref list Feature eligible list" do
		@eligible = PrefListFeature.eligible_list(@player_id, @kingdom.id)
		assert @eligible
		assert @eligible.first.class == Feature
	end
end