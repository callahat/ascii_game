class OldEventQuestConversion < ActiveRecord::Migration
	def self.up
		change_column :events, :text, :text
		EventQuest.all.each{|eq|
			eq.update_attribute(:kind, "EventText") }
	end

	def self.down
		EventText.all.each{|et|
			et.update_attribute(:kind, "EventText") }
		change_column :events, :text, :varchar, :limit => 255
	end
end
