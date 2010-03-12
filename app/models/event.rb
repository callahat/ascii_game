class Event < ActiveRecord::Base
	self.inheritance_column = 'kind'

	belongs_to :player
	belongs_to :kingdom

	has_many :done_events
	has_many :quest_explores
	has_many :feature_events

	validates_presence_of :player_id,:kingdom_id,:name,:event_rep_type
	#validates_uniqueness_of :name
	
	def validate
		if event_rep_type != SpecialCode.get_code('event_rep_type','unlimited')
			if event_reps.nil?
				errors.add('event_reps',' cannot be null')
			elsif event_reps > 9000 || event_reps < 1
				errors.add('event_reps',' must be between 1 and 9000 for event rep types of "limited."')
			end
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
	
	def happens(who)
		if who.health.wellness == SpecialCode.get_code('wellness','dead')
			return {:controller => '/game', :action => 'complete'}, nil, 'You can\'t do that since you are dead.'
		else
			return self.make_happen(who)
		end
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
