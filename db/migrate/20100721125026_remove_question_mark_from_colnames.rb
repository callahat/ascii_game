class RemoveQuestionMarkFromColnames < ActiveRecord::Migration
	def self.up
		rename_column :healing_spells, :cast_on_others? , :cast_on_others
	end

	def self.down
		rename_column :healing_spells, :cast_on_others , :cast_on_others?
	end
end
