class EventQuest < Event
	belongs_to :quest, :foreign_key => 'thing_id'

	#validates_presence_of :thing_id

	def happens(ig=nil)
		return true, text
	end
end
