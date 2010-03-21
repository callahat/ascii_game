class EventDisease < Event
	belongs_to :disease, :foreign_key => 'thing_id'

	validates_presence_of :thing_id
	
	def make_happen(who)
		if self.flex
			if Illness.cure(self.disease, who)
				@message = 'Your case of ' + @disease.name + ' has cleared up!'
			else
				#no point in going on, player already healthy, nothing happens.
				@message = '...Nothing interesting happened.'
			end
		elsif Illness.infect(who, self.disease)
			@message = 'You don\'t feel so good...'
		else
			#don't infect someone with the same organism more than once
			@message = 'This place feels unhealthy'
		end
		
		return nil, EVENT_COMPLETED, @message
	end
	
	def as_option_text(pc=nil)
		if flex
			@link_text = "Cure " + disease.name
		else
			@link_text = "Get infected with " + disease.name
		end
	end
end
