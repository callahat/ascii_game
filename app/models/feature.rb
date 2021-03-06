class Feature < ActiveRecord::Base
  belongs_to :player
  belongs_to :kingdom
  belongs_to :image

  has_many :feature_events, ->{ order('priority') }
  has_many :level_maps
  has_many :world_maps
  has_many :events, through: :feature_events
  has_many :local_move_events, ->{where(kind: 'EventMoveLocal')}, source: :event, through: :feature_events
  has_many :npc_events, ->{where(kind: 'EventNpc').includes(:npc)}, source: :event, through: :feature_events

  validates_presence_of :name,:action_cost,:image_id,:player_id,:kingdom_id,:cost,:num_occupants
  validates_uniqueness_of :name
  validates_numericality_of :action_cost,:cost
  validates_inclusion_of :action_cost, :in => 0..10, :message => ' must be between 0 and 10.'
  validates_inclusion_of :num_occupants , :in => 0..100000, :message => ' must be between 0 and 100,000.'
  validates_inclusion_of :store_front_size , :in => 0..9, :message => ' must be between 0 and 9.'

  def self.sys_gen(name, image_id)
    @sys_gen_feature = Feature.new
    @sys_gen_feature.name = name
    @sys_gen_feature.system_generated = true
    @sys_gen_feature.kingdom_id = -1
    @sys_gen_feature.player_id = -1
    @sys_gen_feature.world_feature = false
    @sys_gen_feature.public = false
    @sys_gen_feature.cost = 0
    @sys_gen_feature.action_cost = 0
    @sys_gen_feature.num_occupants = 0
    @sys_gen_feature.armed = true
    @sys_gen_feature.image_id = image_id
    
    return @sys_gen_feature
  end
  
  #returns two arrays, 1st: events user can choose from, 2nd: events user cannot choose
  def available_events(p, loc, pid, chance=(rand(100)+1) )
    [true, false].inject([]) {|ret, c|
      conds = ['priority = ? and chance >= ? and choice = ?', p, chance, c]
      ret << feature_events.where(conds).includes(:event).inject([]){|a,fe|
        e = fe.event(->{includes(:thing)})
        if (e.class == EventQuest) && (q = e.quest) &&
            (((lq = q.log_quests.find_by(player_character_id: pid)) && lq.rewarded) )
            #|| q.quest_id && DoneQuest.find(:first,:conditions => ['quest_id = ? and player_character_id = ?', q.quest_id, pid ]).nil?)
          a
        elsif e
          case e.event_rep_type
            when SpecialCode.get_code('event_rep_type','unlimited')
              a << e
            when SpecialCode.get_code('event_rep_type','limited')
              ( loc.done_events.where(event_id: e.id).count < e.event_reps ?
                  a << e : a )
            when SpecialCode.get_code('event_rep_type','limited_per_char')
              ( loc.done_events.where(player_character_id: pid, event_id: e.id).count < e.event_reps ?
                  a << e : a )
          end
        else
          Rails.logger.warn "Event was nil for #{self.id} #{feature_events.where(conds)}"
          a
        end
      }
    }
  end
  
  #get the next priority 
  def next_priority(priority)
    pri = feature_events.find_by(['priority > ?', priority])
    return nil unless pri
    pri.priority
  end

  def valid_throne_location
    name == 'Empty' or (name =~ /Throne/ and system_generated)
  end
  
  #Pagination related stuff
  def self.get_page(page, pcid = nil, kid = nil)
    where( (pcid || kid) ? ['player_id = ? or kingdom_id = ?', pcid, kid] : [] ) \
      .order('armed,name') \
      .paginate(:per_page => 15, :page => page)
  end
end
