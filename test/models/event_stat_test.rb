require 'test_helper'

class EventStatTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.first.id,
											:player_id => Player.first.id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
	end

	test "stat event" do
		es = EventStat.find_by_name("Stat event")
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +10 do
			assert_difference '@pc.gold', +500 do
				assert_difference '@pc.experience', +10 do
					assert_difference ['@pc.health.MP','@pc.health.HP'], +30 do
						direct,comp,msg = es.happens(@pc)
						assert comp == EVENT_COMPLETED
						assert msg =~ /explaining/
						@pc.stat.reload
						@pc.health.reload
					end
				end
			end
		end
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = es.happens(@pc)
		assert msg =~ /you are dead/
		assert comp == EVENT_FAILED
	end
	
	test "create stat event" do
		e = EventStat.new(@standard_new)
		assert !e.valid?, e.errors.full_messages.inspect
		assert e.errors.full_messages.size == 1
		e.flex = "9001;25"
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
		StatEventStat.create(:owner_id => e.id, :str => 10)
		HealthEventStat.create(:owner_id => e.id, :HP => 10, :MP => 5)
		assert e.price > 0, e.price.inspect
		assert e.total_cost > 500, e.total_cost.inspect
	end
end