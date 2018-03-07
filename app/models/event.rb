class Event < ActiveRecord::Base
  self.inheritance_column = 'kind'

  belongs_to :player
  belongs_to :kingdom

  has_many :done_events
  has_many :quest_explores
  has_many :feature_events

  validates_presence_of :player_id,:kingdom_id,:name,:event_rep_type
  #validates_uniqueness_of :name
  attr_accessible :player_id,:kingdom_id,:cost,:name, :kind, :event_rep_type, :event_reps, :flex, :thing_id, :text

  class EventRepititionValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record[:event_rep_type] != SpecialCode.get_code('event_rep_type','unlimited')
        if value.nil?
          record.errors[attribute] << 'cannot be null'
        elsif value > 9000 || value < 1
          record.errors[attribute] << 'must be between 1 and 9000 for event rep types of "limited."'
        end
      end
    end
  end

  validates :event_reps, :event_repitition => true

  def price
    0
  end
  
  def self.get_event_types(admin)
    if admin
      return [ ['creature', EventCreature ],
               ['disease', EventDisease ],
               ['item', EventItem ],
               ['level move', EventMoveLocal],
               ['relative move', EventMoveRelative],
               ['quest', EventQuest],
               ['stat', EventStat],
               ['text', EventText] ]
    else
      return [ ['creature', EventCreature ],
               ['item', EventItem ],
               ['level move', EventMoveLocal],
               ['relative move', EventMoveRelative],
               ['quest', EventQuest],
               ['text', EventText] ]
    end
  end
  
  def total_cost
    if self.event_rep_type == SpecialCode.get_code('event_rep_type','unlimited') || self.event_reps > 9000
      500 + self.price * 9000
    elsif self.event_rep_type == SpecialCode.get_code('event_rep_type','limited') 
      500 + self.price * self.event_reps * 2
    else
      500 + self.price * self.event_reps * 5
    end
  end

  def self.sys_gen!(n)
    @event = sys_gen(n)
    @event.save!
    @event
  end

  def self.sys_gen(n)
    @sys_gen_event = self.new(n)
    @sys_gen_event.kingdom_id = -1
    @sys_gen_event.player_id = -1
    @sys_gen_event.armed = 1
    @sys_gen_event.cost = 0
    
    return @sys_gen_event
  end

  #Returns <redirection>, <completion code>, <message>
  def happens(who)
    if who.health.wellness == SpecialCode.get_code('wellness','dead')
      return {:controller => '/game', :action => 'complete'}, EVENT_FAILED, 'You can\'t do that since you are dead.'
    else
      return self.make_happen(who)
    end
  end

  def completes(who)
    #noop for most event types
  end

  def self.new_of_kind(params)
    return Event.new if params.class.to_s !~ /Hash|Event|Parameters/
    return Event.new(params) unless params
    params[:kind] =~ /^(Event(Creature|Disease|Item|MoveLocal|MoveRelative|Quest|Stat|Text)*$)/
    return ($1 ? Rails.module_eval($1).new(params) : Event.new(params.reject{:kind}))
  end
  
  #Pagination related stuff
  def self.get_page(page, pcid = nil, kid = nil)
    where( (pcid || kid) ? ['player_id = ? or kingdom_id = ?', pcid, kid] : [] ) \
      .order('armed,kind,name') \
      .paginate(:per_page => 15, :page => page)
  end
end
