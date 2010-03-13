require 'test_helper'

class EventStatTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@standard_new = {:kingdom_id => Kingdom.find(:first).id,
											:player_id => Player.find(:first).id,
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
						assert comp == true
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
	end
	
	test "create stat event" do
		e = EventStat.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1
		e.flex = "9001;25"
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
end