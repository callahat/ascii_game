class Feature < ActiveRecord::Base
	belongs_to :player
	belongs_to :kingdom
	belongs_to :image

	has_many :feature_events, :order => 'priority'
	has_many :level_maps
	has_many :world_maps
	
	validates_presence_of :name,:action_cost,:image_id,:player_id,:kingdom_id,:cost,:num_occupants
	validates_uniqueness_of :name
	validates_numericality_of :action_cost,:cost
	validates_inclusion_of :action_cost, :in => 0..10, :message => ' must be between 0 and 10.'
	validates_inclusion_of :num_occupants , :in => 0..100000, :message => ' must be between 0 and 100,000.'
	validates_inclusion_of :store_front_size , :in => 0..9, :message => ' must be between 0 and 9.'
	
	def self.sys_gen(name, image_id)
		@sys_gen_feature = Feature.new
		@sys_gen_feature.name = name
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
	def available_events(p, ch, loc, pid)
		[true, false].inject([]) {|ret, c|
			conds = {:conditions => ['priority = ? and chance <= ? and choice = ?', p, ch, c]}
			p feature_events.find(:all, conds)
			p "!!!"
			ret << feature_events.find(:all, conds).inject([]){|a,fe|
				e = fe.event.dup
				case e.event_rep_type
					when SpecialCode.get_code('event_rep_type','unlimited')
						a << e
					when SpecialCode.get_code('event_rep_type','limited')
						( loc.done_events.count(:conditions => {:event_id => e.id}) < e.event_reps ?
								a << e : a )
					when SpecialCode.get_code('event_rep_type','limited_per_char')
						( loc.done_events.count(:conditions => {:player_character_id => pid, :event_id => e.id}) < e.event_reps ?
								a << e : a )
				end
			}
		}
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