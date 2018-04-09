class QuestReq < ActiveRecord::Base
  self.inheritance_column = 'kind'

  belongs_to :quest

  #attr_accessible :quantity, :detail
end
