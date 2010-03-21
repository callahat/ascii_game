require 'test_helper'

class EventDiseaseTest < ActiveSupport::TestCase
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
		@disease = Disease.find_by_name("airbourne disease")
	end
	
	test "disease event" do
		ed = EventDisease.find_by_name("Airborn disease event")
		assert !@pc.illnesses.exists?(:disease_id => ed.thing_id)
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
		assert @pc.illnesses.size == 0
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], -5 do
			direct,comp,msg = ed.happens(@pc)
			assert comp == EVENT_COMPLETED
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 1
		assert @pc.health.wellness == SpecialCode.get_code('wellness','diseased')
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +0 do
			direct,comp,msg = ed.happens(@pc)
			assert msg =~ /unhealthy/
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 1
		
		ed.flex = 1
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +5 do
			direct,comp,msg = ed.happens(@pc)
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 0
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
		assert_difference ['@pc.stat.str','@pc.stat.mag','@pc.stat.dex'], +0 do
			direct,comp,msg = ed.happens(@pc)
			assert msg =~ /Nothing/
			@pc.stat.reload
		end
		assert @pc.illnesses.size == 0
		assert @pc.health.wellness == SpecialCode.get_code('wellness','alive')
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ed.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create disease event" do
		e = EventDisease.new(@standard_new)
		assert !e.valid?
		assert e.errors.full_messages.size == 1
		e.disease = Disease.find(:first)
		assert e.valid?
		assert e.errors.full_messages.size == 0
		assert e.save!
	end
end