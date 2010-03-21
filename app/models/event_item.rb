class EventItem < Event
	belongs_to :item, :foreign_key => 'thing_id'

	validates_presence_of :thing_id,:flex
	validates_inclusion_of :flex, :in => 1..100, :message => ' must be between 1 and 100.'
	
	def make_happen(who)
		#the inventory stuff should probably be modified to use who.inventory.update_items
		PlayerCharacterItem.update_inventory(who.id,self.thing_id,self.flex.to_i)

		return nil, EVENT_COMPLETED, 'Found ' + self.flex + ' ' + self.item.name
	end
	
	def as_option_text(pc=nil)
		"Take " + flex + " " + (flex.to_i > 1 ? item.name.pluralize : item.name)
	end
end
