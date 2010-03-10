class BattleItem < ActiveRecord::Base
	belongs_to :item
	belongs_to :battle
end
