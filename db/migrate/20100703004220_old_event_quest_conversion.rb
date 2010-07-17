class OldEventQuestConversion < ActiveRecord::Migration
	def self.up
		change_column :events, :text, :text
		rename_column :done_quests, :date, :created_at
		EventQuest.all.each{|eq|
			eq.update_attribute(:kind, "EventText") }
	end

	def self.down
		EventText.all.each{|et|
			et.update_attribute(:kind, "EventText") }
		change_column :events, :text, :string, :limit => 255
		rename_column :done_quests, :created_at, :date
	end
end
