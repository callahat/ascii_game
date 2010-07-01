class AddRaceImages < ActiveRecord::Migration
	def self.up
		add_column :races, :image_id, :integer, :default => Image.find_by_name("DEFAULT PC IMAGE").id
	end

	def self.down
		remove_column :races, :image_id
	end
end
