require 'test_helper'

class EventStormGateTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@pc.update_attribute(:in_kingdom, nil)
		@pc.update_attribute(:kingdom_level, nil)
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
		@kingdom = Kingdom.find(1)
	end

	test "storm gate" do
		es = EventStormGate.find_by_name("Storm Kingdom 1 Gate event")
		assert_difference 'Battle.count', +1 do
			@direct, @comp, @msg = es.happens(@pc)
		end
		assert @direct.class == Hash
		assert @direct[:controller] == 'game/battle'
		
		#test where there are no guards
		es.level.kingdom.npcs.destroy_all
		assert_difference 'Battle.count', +0 do
			@direct, @comp, @msg = es.happens(PlayerCharacter.find(1))
		end
		assert @comp == true
		assert @msg =~ /no resistance/
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = es.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create storm gate" do
		e = EventStormGate.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1, e.errors.full_messages
		e.level = Level.find(:first)
		assert e.valid?,e.errors.full_messages
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
end