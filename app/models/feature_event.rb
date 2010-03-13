class FeatureEvent < ActiveRecord::Base
	belongs_to :feature
	belongs_to :event
	
	validates_presence_of :feature_id,:event_id,:chance,:priority
	validates_inclusion_of :chance, :in => 0..100, :message => " must be between 0.0 and 100.0"
	validates_inclusion_of :priority, :in => 0..42, :message => " must be between 0 and 42."
	
	def validate
		if !:event_id.nil?
			if !Event.find(event_id).armed
				errors.add("event_id"," is not armed.")
			end
		end
	end
	
	def self.spawn_gen(h)
		create(h.merge(:chance => 100.0, :priority => 42, :choice => true))
	end
end
