class Kingdom < ActiveRecord::Base
	belongs_to :player_character
	belongs_to :world

	has_one :kingdom_entry

	has_many :races
	has_many :creatures, :order => 'name'
	has_many :events
	has_many :features, :conditions => ['armed = true']
	has_many :all_features, :foreign_key => "kingdom_id", :class_name => "Feature"
	has_many :images, :order => 'name'
	has_many :kingdom_bans
	has_many :kingdom_items
	has_many :levels, :order => 'level'
	has_many :npcs, :order => 'name'
	has_many :guards, :class_name => 'Npc', :include => :health,
										:conditions => ['is_hired = true AND npc_division = ? and healths.wellness != ?',
										SpecialCode.get_code('npc_division','guard'), SpecialCode.get_code('wellness','dead')]
	has_many :live_npcs, :class_name => 'Npc', :include => :health,
											 :conditions => ['healths.wellness != ?', SpecialCode.get_code('wellness','dead')], :order => 'name'
	has_many :pandemics, :foreign_key => 'owner_id'
	has_many :illnesses, :foreign_key => 'owner_id', :class_name => 'Pandemic'
	has_many :player_characters
	has_many :quests, :order => '\'quest_status\',\'name\''
	has_many :quest_kill_n_npcs
	has_many :kingdom_empty_shops
	has_many :kingdom_notices, :order => '"datetime DESC"'
	
	has_many :pref_list_creatures, :include => 'creature', :order => 'creatures.public,creatures.name'
	has_many :pref_list_events, :include => 'event',  :order => 'events.name'
	has_many :pref_list_features, :include => 'feature', :order => 'features.public,features.name'
	
	has_many :pref_lists
	
	def valid_name
		if name.nil? || name == ""
			errors.add('name', 'cannot be empty')
		elsif Kingdom.find_by_name(name)
			errors.add('name', 'is already taken')
		end
		errors.size == 0
	end
	
	def self.pay_tax(tax, kingdom_id)
		Kingdom.transaction do
			@kingdom = self.find(kingdom_id, :lock => true)
			@kingdom.gold += tax
			@kingdom.save!
		end
	end
	
	#returns the number reserved
	def reserve_peasants(peasants)
		@peasants = ( self.num_peasants > peasants ? peasants : self.num_peasants )
		Kingdom.transaction do
			self.lock!
			self.num_peasants -= @peasants
			self.save!
		end
		@peasants
	end
	
	#change the king
	def change_king(pcid)
		Kingdom.transaction do
			self.lock!
			self.player_character = pcid
			self.save!
		end
	end
	
	def self.cannot_spawn(who)
		if who.level < 42
			return "You are not yet powerful enough to found a kingdom"
		elsif who.kingdoms.size > 0
			return "You are already a king somewhere"
		else
			nil
		end
	end
	
	#returns nil 
	def self.spawn_new(who, kname, wm)
		@kingdom = Kingdom.new(:name => kname)
		@ret_kingdom = nil
		@msg = ""
		
		WorldMap.transaction do
			wm.lock!

			unless @msg = Kingdom.cannot_spawn(who)
				if wm.id != (WorldMap.current_tile(wm.bigypos, wm.bigxpos, wm.ypos, wm.xpos)).id
					@msg = "Someone has already founded a kingdom here!"
				elsif @kingdom.valid_name
					make_new_kingdom(who, kname, wm)
				else
					@ret_kingdom = @kingdom
				end
			end
			wm.save!
		end
		
		return @ret_kingdom, @msg
	end

	def self.make_new_kingdom(who, kname, wm)
		@emtpy_feature = Feature.find(:first, :conditions => ['name = ? and kingdom_id = ? and player_id = ?', "\nEmpty", -1, -1])
		@unlimited = SpecialCode.get_code('event_rep_type','unlimited')
		@kingdom = Kingdom.create(:name => kname,
															:player_character_id => who.id,
															:num_peasants => rand(400) + 100,
															:gold => 55000,
															:tax_rate => 5,
															:world_id => wm.world_id,
															:bigx => wm.bigxpos,
															:bigy => wm.bigypos)
		@ec = EventCastle.sys_gen!(:name => "\nCastle #{@kingdom.name} event",
															:event_rep_type => @unlimited)
		@et = EventThrone.sys_gen!(:name => "\nThrone #{@kingdom.name} event",
															:event_rep_type => @unlimited)
		@castle_img = Image.new_castle(@kingdom)
		@castle_feature = Feature.sys_gen("\nCastle #{@kingdom.name}", @castle_img.id)
		@castle_feature.save!
		@castle_fe = FeatureEvent.spawn_gen(:feature_id => @castle_feature.id,
																				:event_id => @ec.id )
		@throne_fe = FeatureEvent.spawn_gen(:feature_id => @castle_feature.id,
																				:event_id => @et.id )
		@level = Level.create(:kingdom_id => @kingdom.id,
													:level => 0,
													:maxy => 3,
													:maxx => 5)
		LevelMap.gen_level_map_squares(@level, @emtpy_feature)
		@castle_location = LevelMap.create(	:level_id => @level.id,
																				:xpos => 2,
																				:ypos => 1,
																				:feature_id => @castle_feature.id)
		@entrance = EventMoveLocal.sys_gen!(:name => "\nKingdom #{@kingdom.name} entrance",
																				:event_rep_type => @unlimited,
																				:thing_id => @level.id )
		@storm_event = EventStormGate.sys_gen!(:name => "\nKingdom #{@kingdom.name} storm event",
																					:event_rep_type => @unlimited,
																					:thing_id => @level.id )
		@kingdom_entrance_feature = Feature.sys_gen("\nKingdom #{@kingdom.name} entrance", @castle_img.id)
		@kingdom_entrance_feature.world_feature = true
		@kingdom_entrance_feature.save!
		@entrance_fe = FeatureEvent.spawn_gen(:feature_id => @kingdom_entrance_feature.id,
																					:event_id => @entrance.id )
		@storm_gate_fe = FeatureEvent.spawn_gen(:feature_id => @kingdom_entrance_feature.id,
																						:event_id => @storm_event.id )
		@new_kingdom = WorldMap.copy(wm)
		@new_kingdom.feature_id = @kingdom_entrance_feature.id
		@new_kingdom.save!
		1.upto(5){ Npc.gen_stock_guard(@kingdom.id) }
		KingdomEntry.create(:kingdom_id => @kingdom.id,
												:allowed_entry => SpecialCode.get_code('entry_limitations','everyone') )
		PlayerCharacter.transaction do
			who.lock!
			who.kingdom_id = @kingdom.id
			who.save!
		end
		
	end
end
