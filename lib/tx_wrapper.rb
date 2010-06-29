#This module contains helpers for single column updates where quantity matters
module TxWrapper

	#Give a record something of what
	def TxWrapper.give(who, what, amount)
		who.class.transaction do
			who.lock!
			who[what] += amount
			who.save!
		end
	end

	#Take, but only if there is enough, otherwise return false
	def TxWrapper.take(who, what, amount)
		who.class.transaction do
			who.lock!
			return(who.save! & false) unless who[what] >= amount
			who[what] -= amount
			who.save!
			return true
		end
	end
end