class QuestReq < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :quest
end
