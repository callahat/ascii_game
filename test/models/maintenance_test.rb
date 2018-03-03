require 'test_helper'

#mostly a smoke test, since the model is really just a container for some methods.
class MaintenanceTest < ActiveSupport::TestCase
	def setup
		@pc = player_characters(:test_pc_one)
		@kingdom = kingdoms(:kingdom_one)
	end
	
	def teardown
		Maintenance.clear_report
	end
	
	test "maint new kingdom npcs" do
		assert Maintenance.report.size == 0
		Maintenance.new_kingdom_npcs(@kingdom)
		assert Maintenance.report.size > 0
	end
	
	test "maint npc solicitation" do
		@kingdom.npcs.destroy_all
	
		assert @kingdom.npcs.size == 0
		Maintenance.npc_solicitation(@kingdom,NpcMerchant)
		Maintenance.npc_solicitation(@kingdom,NpcGuard)
		@kingdom.npcs.reload
		assert @kingdom.npcs.size > 0
		assert Maintenance.report.size >= 0
	end
	
	test "maint kingdom npcs maintenance" do
		assert Maintenance.report.size == 0
		Maintenance.kingdom_npcs_maintenance(@kingdom, @kingdom.live_npcs)
		assert Maintenance.report.size >= 0
	end
	
	test "maint kingdom pandemics" do
		assert Maintenance.report.size == 0
		Maintenance.kingdom_pandemics(@kingdom, @kingdom.live_npcs)
		assert Maintenance.report.size >= 0
	end
	
	#main routine to take care of all the kingdom maintenance that needs done
	test "maint kingdom maintenance" do
		assert Maintenance.report.size == 0
		Maintenance.kingdom_maintenance
		assert Maintenance.report.size > 0
	end
	
	test "maint player character maintenance" do
		assert Maintenance.report.size == 0
		Maintenance.player_character_maintenance
		assert Maintenance.report.size > 0
	end
	
	test "maint creature maintenance" do
		assert Maintenance.report.size == 0
		Maintenance.creature_maintenance
		assert Maintenance.report.size > 0
	end
end