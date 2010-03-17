class CurrentEvent < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :player_character
	belongs_to :event
	
	#Functions for the child classes
	def complete
		
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
		# p "chcoice"
		# p @choices
		# p "auto"
		# p @autos
		
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
	
	def choose_event
		
	end
end
