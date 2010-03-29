require 'test_helper'

class PrefListCreatureTest < ActiveSupport::TestCase
	def setup
		@kingdom = Kingdom.find_by_name("HealthyTestKingdom")
		@player_id = 1
	end

	test "pref list Creature current list" do
		@list = PrefListCreature.current_list(@kingdom)
		assert @list
		assert @list.first.thing.class == Creature
	end

	test "pref list Creature eligible list" do
		@eligible = PrefListCreature.eligible_list(@player_id, @kingdom.id)
		assert @eligible
		assert @eligible.first.class == Creature
	end
end