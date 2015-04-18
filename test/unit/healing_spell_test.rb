require 'test_helper'

class HealingSpellTest < ActiveSupport::TestCase
	test "find spells" do
		assert HealingSpell.find_spells(0).size == 0
		assert HealingSpell.find_spells(3).size == 1
		assert HealingSpell.find_spells(4).size == 1
		assert HealingSpell.find_spells(5).size == 2
		assert HealingSpell.find_spells(50).size == 3
	end

	test "pay casting cost" do
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@hp_heal = HealingSpell.find_by_name("Heal Only")
		
		@pc.health.update_attributes(:MP => 0)
		assert !@hp_heal.pay_casting_cost(@pc)
		assert_equal 0, @pc.health.MP
		
		@pc.health.update_attributes(:MP => 2)
		assert !@hp_heal.pay_casting_cost(@pc)
		assert_equal 2, @pc.health.MP
		
		@pc.health.update_attributes(:MP => 10)
		assert @hp_heal.pay_casting_cost(@pc)
		assert_equal 0, @pc.health.MP
  end
	
	test "cast healing spells" do
		@pc = PlayerCharacter.find_by_name("Test PC One")
		@sars = Disease.find_by_name("airbourne disease")
		@not_sars = Disease.find_by_name("contact disease")
		@hp_heal = HealingSpell.find_by_name("Heal Only")
		@cure_sars = HealingSpell.find_by_name("Cure Sars")
		@cure_and_heal = HealingSpell.find_by_name("Cure Sars and Heal")
		
		@pc.health.update_attributes(:HP => 10)
		Illness.infect(@pc, @sars)
		Illness.infect(@pc, @not_sars)
		
		healed, disease = @hp_heal.cast(@pc, @pc)
		assert_equal 15, healed
		assert_equal 25, @pc.health.HP
		assert disease.nil?
		
		healed, disease = @hp_heal.cast(@pc, @pc)
		assert_equal 5, healed
		assert_equal 30, @pc.health.HP
		assert disease.nil?
		
		@pc.health.update_attributes(:HP => 10)
		healed, disease = @cure_sars.cast(@pc, @pc)
		assert_equal 10, @pc.health.HP
		assert_equal 0, healed
		assert_equal @sars, disease
		
		healed, disease = @cure_sars.cast(@pc, @pc)
		assert_equal 10, @pc.health.HP
		assert_equal 0, healed
		assert disease.nil?
		
		Illness.infect(@pc, @sars)
		healed, disease = @cure_and_heal.cast(@pc, @pc)
		assert_equal 30, @pc.health.HP
		assert_equal 20, healed
		assert_equal @sars, disease
	end
end
