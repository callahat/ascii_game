class EventQuest < Event
	belongs_to :quest, :foreign_key => 'thing_id'

	#validates_presence_of :thing_id

	def make_happen(ig=nil)
		return nil, EVENT_COMPLETED, text
	end
	
	def as_option_text(pc=nil)
		name + " (quest event)"
	end
end
