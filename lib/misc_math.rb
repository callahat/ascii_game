#This module contains number formatting functions
module MiscMath

	#Takes a number and returns the most significant digits and any quantifiers, such as K(ilo) or M(illion)
	def MiscMath.point_recovery_cost(amount)
		(Math.log(amount * 10 + 1) / Math.log(amount + 1.1) ).ceil * 10
	end
	
	def MiscMath.min(x, y)
		( x > y ? y : x)
	end
	
	def MiscMath.max(x, y)
		( x < y ? y : x)
	end
end