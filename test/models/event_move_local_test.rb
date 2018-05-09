require 'test_helper'

class EventMoveLocalTest < ActiveSupport::TestCase
	def setup
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@pc.update_attribute(:in_kingdom, nil)
		@pc.update_attribute(:kingdom_level, nil)
		@standard_new = {:kingdom_id => Kingdom.first.id,
											:player_id => Player.first.id,
											:event_rep_type => SpecialCode.get_code('event_rep_type','unlimited'),
											:name => 'Created event name',
											:armed => 1,
											:cost => 50}
		@kingdom = kingdoms(:kingdom_one)
		@disease = Disease.find_by_name("airbourne disease")
	end
	
	test "local move event when in kingdom" do
		e = EventMoveLocal.find_by_name("local move event")
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.where(['level = -1']).first.id
		
		direct, comp, msg = e.happens(@pc)
		@pc.reload
		assert @pc.present_level == e.level, @pc.kingdom_level.to_s + " " + e.level.to_s
	end
	
	test "local move event when in kingdom and pc dead" do
		e = EventMoveLocal.find_by_name("local move event")
		@pc.in_kingdom = @kingdom.id
		@pc.kingdom_level = @kingdom.levels.where(['level = -1']).first.id
		
		#assert does not fail if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		assert comp == EVENT_COMPLETED
		@pc.reload
		assert @pc.present_level == e.level, @pc.kingdom_level.to_s + " " + e.level.to_s
	end
	
	test "local move event when in world and pc banned" do
		e = EventMoveLocal.find_by_name("local move event")
		ban = KingdomBan.new(:kingdom_id => e.level.kingdom.id, :name => @pc.name)
		ban.player_character_id = @pc.id
		ban.save!
		
		direct, comp, msg = e.happens(@pc)

		assert @pc.in_kingdom.nil?
		assert @pc.kingdom_level.nil?
		assert msg =~ /prevented from entry/
	end
	
	test "local move event when in world pc banned and dead" do
		e = EventMoveLocal.find_by_name("local move event")
		ban = KingdomBan.new(:kingdom_id => e.level.kingdom.id, :name => @pc.name)
		ban.player_character_id = @pc.id
		ban.save!
		
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		
		assert @pc.in_kingdom.nil?
		assert @pc.kingdom_level.nil?
		assert msg =~ /prevented from entry/
	end
	
	test "local move even when in world and no one allowed in" do
		e = EventMoveLocal.find_by_name("local move event")
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','no one'))
	
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom.nil?, @pc.in_kingdom.inspect
		assert @pc.kingdom_level.nil?
		assert msg =~ /one may enter/
	end
	
	test "local move even when in world and no one allowed in and pc dead" do
		e = EventMoveLocal.find_by_name("local move event")
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','no one'))
		
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		
		assert @pc.in_kingdom.nil?, @pc.in_kingdom.inspect
		assert @pc.kingdom_level.nil?
		assert msg =~ /one may enter/
	end
	
	test "local move event when in world only allies pc not ally" do
		e = EventMoveLocal.find_by_name("local move event")
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','allies'))
		
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom.nil?, @pc.in_kingdom.inspect
		assert @pc.kingdom_level.nil?
		assert msg =~ /Only the kings men may pass/
	end
	
	test "local move event when in world only allies pc not ally and dead" do
		e = EventMoveLocal.find_by_name("local move event")
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','allies'))
		
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		
		assert @pc.in_kingdom.nil?, @pc.in_kingdom.inspect
		assert @pc.kingdom_level.nil?
		assert msg =~ /Only the kings men may pass/
	end
	
	test "local move event when in world only allies pc ally" do
		e = EventMoveLocal.find_by_name("local move event")
		@pc.update_attribute(:kingdom_id, @kingdom.id)
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','allies'))
		
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom == @kingdom.id
		assert @pc.present_level.level == 0
		assert msg =~ /Entered/
	end
	
	test "local move event when in world only allies pc ally and pc dead" do
		e = EventMoveLocal.find_by_name("local move event")
		@pc.update_attribute(:kingdom_id, @kingdom.id)
		@kingdom.kingdom_entry.update_attribute(:allowed_entry, SpecialCode.get_code('entry_limitations','allies'))
		
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		
		assert @pc.in_kingdom == @kingdom.id
		assert @pc.present_level.level == 0
		assert msg =~ /Entered/
	end
	
	test "local move event everyone can enter" do
		e = EventMoveLocal.find_by_name("local move event")
		direct, comp, msg = e.happens(@pc)
		assert @pc.in_kingdom == @kingdom.id
		assert @pc.present_level.level == 0
		assert msg =~ /Entered/
	end
	
	test "local move event everyone can enter and pc dead" do
		e = EventMoveLocal.find_by_name("local move event")
		
		direct, comp, msg = e.happens(@pc)
		assert msg !~ /you are dead/
		
		assert @pc.in_kingdom == @kingdom.id
		assert @pc.present_level.level == 0
		assert msg =~ /Entered/
	end
	
	test "local move event infect kingdom" do
		e = EventMoveLocal.find_by_name("local move event")
		Illness.infect(@pc, @disease)
		assert @pc.illnesses.size == 1
		assert_difference '@kingdom.illnesses.size', +1 do
			@direct, @comp, @msg = e.happens(@pc)
			@kingdom.reload
		end
	end
	
	test "local move event catch disease from kingdom" do
		e = EventMoveLocal.find_by_name("local move event")
		Illness.infect(@kingdom, @disease)
		assert @kingdom.illnesses.size == 1
		assert_difference '@pc.illnesses.size', +1 do
			@direct, @comp, @msg = e.happens(@pc)
			@pc.reload
		end
		assert @msg =~ /You don't feel so good/
	end
	
	test "create local move event" do
		e = EventMoveLocal.new(@standard_new)
		assert !e.valid?
		assert_equal 1, e.errors.full_messages.size
		e.thing_id = Level.first.id
		assert e.valid?
		assert_equal 0, e.errors.full_messages.size
		assert e.save!
		assert_equal 0, e.price
		assert_equal 500, e.total_cost
	end
end
