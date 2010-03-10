class SpecialCode < ActiveRecord::Base
	#This is just a wrapper class now. No more hits to the database.
	#Could eventually replace the function calls to this with a reference to the constant hash

	def self.get_code(type,txt)
		SPEC_CODET[type][txt]
	end

	def self.get_text(type,code)
		SPEC_CODEC[type][code]
	end
end