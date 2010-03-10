class QuestKillNNpc < QuestReq
	#belongs_to :kingdom

	has_many :log_quest_kill_n_npcs
	
	validates_presence_of :quest_id,:quantity,:detail
	validates_inclusion_of :quantity, :in => 1..100000, :message => ' must be between 1 and 100000.'
	
	def to_sentence
		division = SpecialCode.get_text('npc_division', self.detail.split(":")[0].to_i )
		kingdom = Kingdom.exists?(self.detail.split(":")[1]) && Kingdom.find(self.detail.split(":")[1]).name
		location = " of " + kingdom if kingdom
		"Kill " + self.quantity.to_s + " " + ( self.quantity > 1 ? division.pluralize : division ) + location + "."
end
end
