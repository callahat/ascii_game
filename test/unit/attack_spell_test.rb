require 'test_helper'

class AttackSpellTest < ActiveSupport::TestCase
	def setup 
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@weak = AttackSpell.find_by_name("Weak Attack Spell")
		@mphp = AttackSpell.find_by_name("MP and HP Attack Spell")
	end

	test "find spells" do
		assert AttackSpell.find_spells(0).size == 0
		assert AttackSpell.find_spells(3).size == 0
		assert AttackSpell.find_spells(5).size == 2
		assert AttackSpell.find_spells(11).size == 3
		assert AttackSpell.find_spells(50).size == 4
  end

	test "pay casting cost" do
		@pc.health.update_attributes(:MP => 0)
		assert !@weak.pay_casting_cost(@pc)
		assert @pc.health.MP == 0
		
		@pc.health.update_attributes(:MP => 2)
		assert !@weak.pay_casting_cost(@pc)
		assert @pc.health.MP == 2
		
		@pc.health.update_attributes(:MP => 10)
		assert @weak.pay_casting_cost(@pc)
		assert @pc.health.MP == 5,@pc.health.MP
		
		@pc.health.update_attributes(:HP => 5, :MP => 5)
		assert !@mphp.pay_casting_cost(@pc)
		assert @pc.health.MP == 5
		assert @pc.health.HP == 5
		
		@pc.health.update_attributes(:HP => 35, :MP => 5)
		assert !@mphp.pay_casting_cost(@pc)
		assert @pc.health.MP == 5
		assert @pc.health.HP == 35
		
		@pc.health.update_attributes(:HP => 5, :MP => 55)
		assert !@mphp.pay_casting_cost(@pc)
		assert @pc.health.MP == 55
		assert @pc.health.HP == 5
		
		@pc.health.update_attributes(:HP => 10, :MP => 20)
		assert @mphp.pay_casting_cost(@pc)
		assert @pc.health.MP == 5
		assert @pc.health.HP == 0
end
end
