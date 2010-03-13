class LocableMaptiles < ActiveRecord::Migration
	def self.up
		add_column :world_maps, :lock, :boolean, :default => false
		add_column :level_maps, :lock, :boolean, :default => false
	end

	def self.down
		remove_column :world_maps, :lock
		remove_column :level_maps, :lock
	end
end
