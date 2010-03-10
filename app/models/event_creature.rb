class EventCreature < ActiveRecord::Base
	belongs_to :event
	belongs_to :creature

	validates_presence_of :event_id,:creature_id,:low,:high
	validates_inclusion_of :low, :in => 1..500, :message => ' must be between 1 and 500'
	validates_inclusion_of :high, :in => 1..500, :message => ' must be between 1 and 500'

	def validate
		if !low.nil? && !high.nil? && (low > high)
			errors.add("low", " must be less than or equal to high.")
		end
	end

end
