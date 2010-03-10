class Event < ActiveRecord::Base
	belongs_to :player
	belongs_to :kingdom

	has_many :done_events
	has_many :quest_explores
	has_many :feature_events

	has_one :event_move
	has_one :event_stat
	has_one :event_player_character
	has_one :event_creature
	has_one :event_disease
	has_one :event_item
	has_one :event_npc
	has_many :event_npcs
	has_one :event_quest
	has_one :event_storm_gate

	validates_presence_of :player_id,:kingdom_id,:name,:event_rep_type,:event_type
	#validates_uniqueness_of :name
	
	def validate
		if event_rep_type != SpecialCode.get_code('event_rep_type','unlimited')
			if event_reps.nil?
				errors.add('event_reps',' cannot be null')
			elsif event_reps > 9000 || event_reps < 1
				errors.add('event_reps',' must be between 1 and 9000 for event rep types of "limited."')
			end
		end
		if name.nil?
			errors.add('name',' cannot but null.')
		elsif !Event.find(:first, :conditions => ['name = ?', name]).nil? && name != "\nSYSTEM GENERATED"
			errors.add('name',' has already been taken.')
		end
	end
	
	def self.sys_gen(name, event_type, event_rep_type, reps)
		@sys_gen_event = Event.new
		@sys_gen_event.kingdom_id = -1
		@sys_gen_event.player_id = -1
		@sys_gen_event.event_rep_type = event_rep_type
		@sys_gen_event.event_reps = reps
		@sys_gen_event.name = name
		@sys_gen_event.event_type = event_type
		@sys_gen_event.armed = 1
		@sys_gen_event.cost = 0
		
		return @sys_gen_event
	end
	
	def event_subs
		@subs = []
		@subs << event_move
		@subs << event_stat
		@subs << event_player_character
		@subs << event_creature
		@subs << event_disease
		@subs << event_item
		@subs << event_npc
		@subs << event_npcs
		@subs << event_quest
		@subs << event_storm_gate
		
		@subs.flatten!.delete(nil)
		
		return @subs
	end
	
	#Pagination related stuff
	def self.per_page
		15
	end
	
	def self.get_page(page, pcid = nil, kid = nil)
		if pcid.nil? && kid.nil?
		paginate(:page => page, :order => 'armed,event_type,name' )
	else
			paginate(:page => page, :conditions => ['player_id = ? or kingdom_id = ?', pcid, kid], :order => 'armed,event_type,name' )
	end
	end
end
