class CurrentEvent < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :player_character
	belongs_to :event
	
	#Functions for the child classes
	def complete
		case self.completed
			when EVENT_COMPLETED
				self.make_done_event if self.event.event_rep_type != SpecialCode.get_code('event_rep_type','unlimited')
				self.event.completes(self.player_character)
				LogQuestExplore.complete_req(self.player_character_id, event_id) #probably should happen through 
			when EVENT_FAILED
				return [nil,nil]
			#when EVENT_SKIPPED
			when EVENT_INPROGRESS
				return [self.priority, self.event]
		end
		return self.next_event
	end

	#Returns [next priority, next event], or [next priority, array of events] if pc can choose, or nil if no events
	def next_event
		f = location.feature
		@next = self.priority
		begin
			@next = f.next_priority(@next)
			return [nil,nil] unless @next
			@choices, @autos = f.available_events(@next, location, player_character.id)
		end while @autos.size + @choices.size == 0
		
		if @autos.size > 0 && @choices.size > 0
			@pick = rand(@autos.size + @choices.size)
			if @pick < @autos.size
				return @next, @autos[@pick]
			else
				return @next, @choices
			end
		elsif @autos.size > 0
			return @next, @autos[rand(@autos.size).to_i]
		else # @choices.size > 0
			return @next, @choices
		end
	end
	
	#def choose_event(eid)
	#end
	
	def self.make_new(pc, lid)
		if pc.in_kingdom
			CurrentKingdomEvent.create(:player_character_id => pc.id, :location_id => lid)
		else
			CurrentWorldEvent.create(:player_character_id => pc.id, :location_id => lid)
		end
	end
end
