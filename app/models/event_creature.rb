class EventCreature < Event
  belongs_to :creature, :foreign_key => 'thing_id'
  belongs_to :thing, :foreign_key => 'thing_id', :class_name => 'Creature'

  validates_presence_of :thing_id,:flex
  
  def price
    low, high = flex.split(";")
    (creature.gold + (creature.experience / (creature.number_alive + 5))) * (high.to_i - low.to_i - 1)
  end
  
  def make_happen(who)
    low, high = flex.split(";").collect{|c| c.to_i}
    result, msg = Battle.new_creature_battle(who, self.creature, low.to_i, high.to_i, who.present_kingdom)
    if result
      return url_helpers.battle_game_battle_path, EVENT_INPROGRESS, "You encounter monsters!"
    else
      return nil, EVENT_COMPLETED, msg
    end
  end

  class FlexRangeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      low, high = value.split(";").collect{|c| c.to_i}
      if !low.nil? && !high.nil? && (low > high)
        record.errors[attribute] << "low must be less than or equal to high."
      end
      if low.nil? || low < 1 || low > 500
        record.errors[attribute] << "low must be between 1 and 500."
      end
      if high.nil? || high < 1 || high > 500
        record.errors[attribute] << "high must be between 1 and 500."
      end
    end
  end

  validates :flex, :flex_range => true
  
  def as_option_text(pc=nil)
    "Fight some " + creature.name.pluralize
  end
end
