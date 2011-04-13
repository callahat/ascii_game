class DoneEvent < ActiveRecord::Base
  self.inheritance_column = 'kind'

  belongs_to :player_character
  belongs_to :event
end
