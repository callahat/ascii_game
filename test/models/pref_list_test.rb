require 'test_helper'

class PrefListTest < ActiveSupport::TestCase
	def setup
		@kingdom = Kingdom.find_by_name("HealthyTestKingdom")
		@c = Creature.find_by_name("Tough Monster")
		@f = Feature.find_by_name("Feature Nothing")
		@e = Event.find_by_name("Sick PC encounter")
		
		@cp = Creature.find_by_name("Wimp Monster")
		@fp = Feature.find_by_name("Creature Feature One")
		@ep = Event.find_by_name("Weak Monster encounter")
	end

	test "add to pref list" do
		[[PrefListCreature, @c], [PrefListEvent, @e], [PrefListFeature, @f]].each{ |c|
			assert_difference 'c[0].count', +1 do
				c[0].add(@kingdom.id, c[1].id)
			end
			assert_difference 'c[0].count', +0 do
				c[0].add(@kingdom.id, c[1].id)
			end
		}
	end

	test "drop from pref list" do
		[[PrefListCreature, @cp], [PrefListEvent, @ep], [PrefListFeature, @fp]].each{ |c|
			assert_difference 'c[0].count', -1 do
				c[0].drop(@kingdom.id, c[1].id)
			end
			assert_difference 'c[0].count', +0 do
				c[0].drop(@kingdom.id, c[1].id)
			end
		}
	end
end