class EventDisease < Event
	belongs_to :disease, :foreign_key => 'thing_id'

	validates_presence_of :thing_id
	
	def happens(who)
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
		
		return true, @message
	end
end
