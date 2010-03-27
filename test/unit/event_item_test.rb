require 'test_helper'

class EventItemTest < ActiveSupport::TestCase
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
	
	test "item event" do
		ei = EventItem.find_by_name("Item event")
		assert @pc.items.find(:all, :conditions => {:item_id => ei.thing_id}).size == 0
		assert ei.item.name == "Cool item"
		assert_difference '@pc.items.size', +1 do
			direct,comp,msg = ei.happens(@pc)
			@pc.items.reload
		end
		assert @pc.items.find(:first, :conditions => {:item_id => ei.thing_id}).quantity == 3
		
		assert_difference '@pc.items.size', +0 do
			direct,comp,msg = ei.happens(@pc)
			@pc.items.reload
		end
		assert @pc.items.find(:first, :conditions => {:item_id => ei.thing_id}).quantity == 6
		
		#assert fails if pc dead
		@pc.health.update_attribute(:wellness, SpecialCode.get_code('wellness','dead'))
		direct, comp, msg = ei.happens(@pc)
		assert msg =~ /you are dead/
	end
	
	test "create item event" do
		e = EventItem.new(@standard_new.merge(:flex => 105))
		assert !e.valid?
		assert e.errors.full_messages.size == 2
		e.item = Item.find_by_name("Item99")
		assert !e.valid?
		assert e.errors.full_messages.size == 1, e.errors.full_messages.size
		e.flex = 4
		assert e.valid?,e.errors.full_messages
		assert e.errors.full_messages.size == 0
		assert e.save!
		assert e.price >= e.item.price, e.price
		assert e.total_cost > 500, e.total_cost
	end
end