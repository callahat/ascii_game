class QuestItem < QuestReq
	belongs_to :item, :foreign_key => 'detail'
	
	validates_presence_of :quest_id,:detail,:quantity
	validates_inclusion_of :quantity,:in => 1..2000, :message => ' must be between 1 and 2000.'
	
	def to_sentence
		"Retrieve" + self.quantity.to_s + " " + (self.quantity > 1 ? self.item.name.pluralize : self.item.name) +"."
	end
end
