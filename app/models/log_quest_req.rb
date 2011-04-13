class LogQuestReq < ActiveRecord::Base
  self.inheritance_column = 'kind'
  
  belongs_to :log_quest
  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'PlayerCharacter'
end
