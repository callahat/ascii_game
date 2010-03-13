class CreateIllnesses < ActiveRecord::Migration
	def self.up
		create_table :illnesses do |t|
			t.integer "owner_id",																		:null => false
			t.integer "disease_id",																	:null => false
			t.integer "day",												:default => 1
			t.string  "kind",					:limit => 20,	:default => "",	:null => false
		end
		add_index "illnesses", ["owner_id"], :name => "owner_id"
		add_index "illnesses", ["disease_id"], :name => "disease_id"
		add_index "illnesses", ["day"], :name => "day"
		add_index "illnesses", ["kind","owner_id"], :name => "kind_owner_id"
		add_index "illnesses", ["kind","owner_id","disease_id"], :name => "kind_owner_id_disease_id"

		Illness.transaction do
			Infection.find_by_sql('select * from `infections`').each{ |i|
				Infection.create(:owner_id => i.character_id, :disease_id => i.disease_id) }
			NpcDisease.find_by_sql('select * from `npc_diseases`').each{ |i|
				NpcDisease.create(:owner_id => i.character_id, :disease_id => i.disease_id) }
			Pandemic.find_by_sql('select * from `pandemics`').each{ |i|
				Pandemic.create(:owner_id => i.kingdom_id, :disease_id => i.disease_id, :day => i.day) }
		end

		drop_table :infections
		drop_table :npc_diseases
		drop_table :pandemics
	end

	def self.down
		raise raise ActiveRecord::IrreversibleMigration
		#For this migration to be reversible, the models must be rewritten
		#to not use single table inheritence
		#drop_table :illnesses
	end
end
