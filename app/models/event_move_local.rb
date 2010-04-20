class EventMoveLocal < EventLifeNeutral
	belongs_to :level, :foreign_key => 'thing_id', :class_name => 'Level'
	
	validates_presence_of :thing_id
	
	def make_happen(who)
		PlayerCharacter.transaction do
			who.lock!
			if who.in_kingdom
				if who.in_kingdom == self.level.kingdom_id
					who.kingdom_level = self.thing_id
					@message = "Moved to level " + self.level.level.to_s
				else
					@message = "Look before you leap, that route won't take you where you can go"
				end
			else
				@inf_flag = false #flag that will be true if player can enter kingdom, and contact possible disease
			
				#gotta check for the player not being allowed in.
				if who.kingdom_bans.find(:first, :conditions => ['kingdom_id = ?', self.level.kingdom_id] )
					@message = '"You are prevented from entry, by order of the king" a gaurd shouts'
				elsif SpecialCode.get_code('entry_limitations','no one') == self.level.kingdom.kingdom_entry.allowed_entry
					@message = '"No one may enter the kingdom today" the gaurd explains'
				elsif SpecialCode.get_code('entry_limitations','allies') == self.level.kingdom.kingdom_entry.allowed_entry
					if who.kingdom_id == self.level.kingdom_id
						who.in_kingdom = self.level.kingdom_id
						who.kingdom_level = self.thing_id
						@message = "Entered " + self.level.kingdom.name
						@inf_flag = true
					else
						@message = '"Hold! Only the kings men may pass today" says the guard'
					end
				else #everyone can come on in
					who.in_kingdom = self.level.kingdom_id
					who.kingdom_level = self.thing_id
					@message = "Entered " + self.level.kingdom.name
					@inf_flag = true
				end
			end
			who.save!
		end
		
		#diseases spread!
		if @inf_flag
			@kingdom = who.present_kingdom
			Illness.spread(who, @kingdom, SpecialCode.get_code('trans_method','air'))
			if Illness.spread(@kingdom, who, SpecialCode.get_code('trans_method','air'))
				@message += "\nYou don't feel so good ..."
			end
		end
		
		return {:action => 'complete'}, EVENT_COMPLETED, @message
	end
	
	def as_option_text(pc=nil)
		if pc && pc.in_kingdom.nil?
			@link_text = "Enter " + level.kingdom.name
		else
			@link_text = "Go to level " + level.level.to_s
		end
	end
end
