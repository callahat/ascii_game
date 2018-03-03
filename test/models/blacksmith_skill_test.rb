require 'test_helper'

class BlacksmithSkillTest < ActiveSupport::TestCase
	test "find base items" do
		@array = BlacksmithSkill.find_base_items(0, -1).collect{|b| b.id}
		assert @array.size == 3
		assert @array.index(blacksmith_skills(:blacksmith_skill_initial1).id)
		assert @array.index(blacksmith_skills(:blacksmith_skill_initial2).id)
		assert @array.index(blacksmith_skills(:blacksmith_skill_initial3).id)
		
		@array = BlacksmithSkill.find_base_items(0, -1, SpecialCode.get_code('race_body_type','human') ).collect{|b| b.id}
		assert @array.size == 3
		assert @array.index(blacksmith_skills(:blacksmith_skill_initial1).id)
		assert @array.index(blacksmith_skills(:blacksmith_skill_initial2).id)
		assert @array.index(blacksmith_skills(:blacksmith_skill_initial3).id)
		
		@array = BlacksmithSkill.find_base_items(10, 0).collect{|b| b.id}
		assert @array.size == 0
		
		@array = BlacksmithSkill.find_base_items(0, -1, SpecialCode.get_code('race_body_type','insect') ).collect{|b| b.id}
		assert @array.size == 1
		assert @array.index(blacksmith_skills(:blacksmith_skill_initial2).id)
		
		@array = BlacksmithSkill.find_base_items(10000, 499, SpecialCode.get_code('race_body_type','human') ).collect{|b| b.id}
		assert @array.size == 1
		assert @array.index( blacksmith_skills(:blacksmith_skill_intermediate1).id )
		
		@array = BlacksmithSkill.find_base_items(500, 0, SpecialCode.get_code('race_body_type','human') ).collect{|b| b.id}
		assert @array.size == 1
		assert @array.index( blacksmith_skills(:blacksmith_skill_intermediate1).id )
	end
end
