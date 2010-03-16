class CurrentEvent < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :player_character
	belongs_to :event
	
	#Functions for the child classes
	def complete
		
	end
	
	#Returns next event, or array of events if pc can choose, or nil if no events
	def next_event
		f = location.feature
		@autos, @choices = f.available_events(@next, rand(100), location, player_character.id)
		
		if @autos.size > 0 && @choices.size > 0
			@pick = rand(@autos.size + @choices.size)
			if @pick < @autos.size
				@autos[@pick].event
			else
				@choices
			end
		elsif @autos.size > 0 && @choices.size == 0
			session[:current_event] = @autos[rand(@autos.size).to_i].event
		elsif @autos.size == 0 && @choices.size > 0
			@choices
		else
			nil
		end
	end
	
	def choose_event
		
	end
	
	def next_priority
		p = feature.feature_events.find(:first, :conditions => ['priority > ?', priority])
		return nil unless p
		p.priority
	end
end
