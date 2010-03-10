#This is just an object to simplify all the mainenance crap.
#This will allow 
class Maintenance < ActiveRecord::Base

	#Allocate NPCs/create NPCs and assign to existing kingdom
	def self.new_kingdom_npcs(kingdom)
		if SystemStatus.find(1).status == 1	#abort if the system is running
			print "\nSytem is running, aborting..."
			return
		end
	
		print "\nNEW KINGDOM NPCS FOR " + kingdom.name
		@unhireds = kingdom.npcs.find(:all, :conditions => ['is_hired = ?', 0])
		
		for unhired in @unhireds
			if rand > 0.75
				unhired.kingdom_id = nil
				unhired.save
			end
		end
		
		@unhired_merchants = kingdom.npcs.find(:all, :conditions => ['npc_division = ? and is_hired = ?', SpecialCode.get_code('npc_division','merchant'), 0])
		@unhired_guards = kingdom.npcs.find(:all, :conditions => ['npc_division = ? and is_hired = ?', SpecialCode.get_code('npc_division','guard'), 0])
		
		#if space for new MERCHANTS
		if @unhired_merchants.size < kingdom.kingdom_empty_shops.size * 1.5
			npc_solicitation(kingdom,SpecialCode.get_code('npc_division','merchant'))
		end
		
		#if space for new GUARDS
		if kingdom.player_character	#if no king, no guards will go
			npc_solicitation(kingdom,SpecialCode.get_code('npc_division','guard'))
		end
	end
	
	def self.npc_solicitation(kingdom,npc_division)
		if SystemStatus.find(1).status == 1	#abort if the system is running
			print "\nSytem is running, aborting..."
			return
		end
	
		if @unhired_merchants.size < kingdom.player_character.level * 2
			@npc_from_pool = Npc.find(:first,:conditions => ['kingdom_id is NULL AND npc_division = ?', npc_division],
															:offset => Npc.count(:conditions => ['kingdom_id is NULL AND npc_division = ?', npc_division]))
			if @npc_from_pool.nil? || rand > 0.75
				if npc_division == SpecialCode.get_code('npc_division','guard')
					@new_guy = Npc.gen_stock_guard(kingdom.id)
				elsif npc_division == SpecialCode.get_code('npc_division','merchant')
					@new_guy = Npc.gen_stock_merchant(kingdom.id)
				end
				print "\n" + @new_guy.name + " entered the job market"
			else
				@npc_from_pool.kingdom = kingdom.id
				@npc_from_pool.save
				print "\n" + @npc_from_pool.name + " is looking for employment"
			end
		end
	end
	
	#NPCs gain stat bonuses
	#Blacksmiths check to see if they can make a new item
	#NPC's gain some stat gains
	#NPCs HP and MP restored, unless they have a disease fatal to NPCs
	#NPC's take damage from infections
	def self.kingdom_npcs_maintenance(kingdom, npcs)
		if SystemStatus.find(1).status == 1	#abort if the system is running
			print "\nSytem is running, aborting..."
			return
		end
	
		for npc in npcs
			#get the disease damage toll first
			@disease_damage =0
			for infection in npc.illnesses
				@disease_damage += infection.disease.HP_per_turn
			end
		
			#lock NPC, just to be safe
		Npc.transaction do
			npc.lock!
				npc.stat.lock!
				npc.health.lock!
		
				npc.stat.con += rand(4)
				npc.stat.dam += rand(4)
				npc.stat.dex += rand(4)
				npc.stat.dfn += rand(4)
				npc.stat.int += rand(4)
				npc.stat.mag += rand(4)
				npc.stat.str += rand(4)
				npc.gold = rand(500)
				npc.experience += rand(50)
			
				npc.health.base_HP += rand(7)
			
				@terminal_diseases = npc.illnesses.find(:all, :include => 'disease', :conditions => ['diseases.NPC_fatal = true'])
			
				if @terminal_diseases.size > 0
					npc.health.HP -= @disease_damage
					if npc.health.HP <= 0
						npc.health.wellness = SpecialCode.get_code('wellness','dead')
					
						#make kingdom notice
						@notice = KingdomNotice.new
						@notice.kingdom_id = kingdom.name
						@notice.shown_to = SpecialCode.get_code('shown_to','everyone')
						@notice.datetime = Time.now
						@notice.text = npc.name + " died from " + @terminal_diseases[rand(@terminal_diseases.size)].disease.name + "."
						@notice.signed = "Minister of Health and Sanitation"
						@notice.save
					end
				else
					npc.health.HP = npc.health.base_HP
					npc.health.HP -= @disease_damage
					npc.health.HP = [@npc.health.HP,1].max
				end
		npc.save!
				npc.stat.save!
				npc.health.save!
			end
			
			if npc.health.wellness == SpecialCode.get_code('wellness','dead')
			print "This is a dead NPC :'("
			else
				#next steps involve determining division of the NPC. if a guard, then we're done. Otherwise,
				#if its a merchant, there is some more stuff we need to do
				if npc.npc_merchant
					if npc.npc_merchant.healing_sales.to_i > 0
						#can any pandemics be cured?
						for pandemic in kingdom.pandemics
							if HealerSkill.find(:first, :conditions => ['disease_id = ? AND min_sales <= ?', pandemic.disease_id, npc.npc_merchant.healing_sales]) && rand(pandemic.disease.virility) < npc.int / 10	#then NPC has cured the pandemic
								create_pandemic_notice(kingdom, npc.name + " has discovered a cure for the " + pandemic.disease.name + " pandemic which had been tormenting the kingdom for " + pandemic.day + " days.")
								pandemic.destroy
							end
						end
					end
					if npc.npc_merchant.blacksmith_sales.to_i > 0
						#see if new items can be made, items have 50/50 chance outright of being new vs 
						#regular stock items.
						NpcBlacksmithItem.gen_blacksmith_items(npc, npc.npc_merchant.blacksmith_sales, rand(1))
					end
			#Nothing needs done if npc is trainer
				end
			end
		end #end FOR
	end
	
	#Spread pandemics to/from NPC's to/from the general peasant population
	#kill off some peasants from disease, pandemic lifted if population lower than min to 
	#sustain the disease
	def self.kingdom_pandemics(kingdom, npcs)
		if SystemStatus.find(1).status == 1	#abort if the system is running
			print "\nSytem is running, aborting..."
			return
		end
	
		@dead_from_disease = 0
		@pandemics = kingdom.pandemics
		for pandemic in @pandemics
			#npc catch?
			pandemic.day += 1
			pandemic.save
			
			#only airbourne can be spread
			if pandemic.disease.trans_method == SpecialCode.get_code('trans_method','air')
				for npc in npcs
					Illness.infect(npc, pandemic.disease)
				end
			end
		
		Kingdom.transaction do
				kingdom.lock!
			
				if kingdom.num_peasants < pandemic.disease.min_peasants
					#not enough peasants, pandemic ends
					create_pandemic_notice(kingdom, "The number of cases of " + pandemic.disease.name + " has greatly diminished, ending the " + pandemic.day.to_s + " pandemic.")
					pandemic.destroy
				else
					@fatality = pandemic.disease.peasant_fatality
					@fatality = @fatality / 2.0 + rand(@fatality / 2.0)
					@deaths = (kingdom.num_peasants * (@fatality / 100.0)).to_i
				
					@dead_from_disease += @deaths
				
					#notice for deaths
					create_pandemic_notice(kingdom, @deaths.to_s + " peasants died from " + pandemic.disease.name)
					kingdom.num_peasants -= @deaths
				end
			
				kingdom.lock!
			end
		end
		return @dead_from_disease
	end
	
	
	#main routine to take care of all the kingdom maintenance that needs done
	def self.kingdom_maintenance
		if SystemStatus.status(1) == 1	#abort if the system is running
			print "\nSytem is running, aborting..."
			return false
		end
	
		@kingdoms = Kingdom.find(:all, :conditions => ['id > 0'])
		@updates = 0
		for kingdom in @kingdoms
			print "\nMaintenance for " + kingdom.name
		
			@npcs = kingdom.live_npcs
			@disease_deaths = kingdom_pandemics(kingdom, @npcs)
			
			kingdom_npcs_maintenance(kingdom, @npcs)
			
			#taxes and new peasants
		Kingdom.transaction do
				kingdom.lock!
		
				@tax_revenue = (kingdom.num_peasants * kingdom.tax_rate / 1000.0).to_i
				@immigrants = 3 + (100 - (kingdom.tax_rate ** 2) / 100.0).to_i
				@births = ((rand(10) + kingdom.num_peasants) * [100 - kingdom.tax_rate ** 2, 1].max / 100.0).to_i
				@emmigrants = [kingdom.housing_cap - kingdom.num_peasants, 0].min / (rand(10)+1)	 #everyone will not necessarily leave due to overcrowding
			
				create_pop_change_notice(kingdom,@immigrants,@emmigrants,@births,@disease_deaths)
			
				kingdom.num_peasants += @births + @immigrants - @emmigrants
				kingdom.gold += @tax_revenue
			
				kingdom.save!
			end
			
			#take care of the new NPC stuff, only if there is a king
			if kingdom.player_character_id
				new_kingdom_npcs(kingdom)
			end
			@updates += 1
		end
		@updates
	end
	
	#main routine to take care of all the player maintenance that needs done
	#mostly just gives players characters more time units, but could be expanded later.
	def self.player_character_maintenance
		if SystemStatus.status(1) == 1	#abort if the system is running
			print "\nSytem is running, aborting..."
			return false
		end
	
		#add turns for player characters that are active only. 
		@player_characters = PlayerCharacter.find(:all, :conditions => ['char_stat = ?', SpecialCode.get_code('char_stat','active')])
		@alive_code = SpecialCode.get_code('wellness','alive')
		@dead_code = SpecialCode.get_code('wellness','dead')
		@updated_count = 0
		for pc in @player_characters
			#might as well get the lock
		PlayerCharacter.transaction do
				pc.lock!
				print "\nUpdating PC #" + pc.id.to_s + " " + pc.name
				if pc.turns > 320
					print "\n gained " + (400 - pc.turns).to_s + " turns."
					pc.turns = 400
				else
					print "\n gained 80 turns."
					pc.turns += 80
				end
				pc.save!
			
				pc.health.lock!
				#if not alive, no point in damage from disease and checking to see if it killed themz
				if pc.health.wellness == @alive_code
					for infection in pc.illnesses	 #take health away at end of day, ratehr than for every turn
						#future thing to add: see if the pc has th constitution to just immunize to the disease
				
						pc.health.HP -= infection.disease.HP_per_turn
						pc.health.MP -= infection.disease.MP_per_turn
						print "\n " + infection.disease.name + " causes " + infection.disease.HP_per_turn.to_s + " HP, " + infection.disease.MP_per_turn.to_s + " MP damage."
					end
			
					#see if PC still alive.
					if pc.health.HP <= 0
						pc.health.wellness = @dead_code
						print "\n Died from untreated disease."
					end
				end
			
				pc.health.save!
			end
			@updated_count += 1
		end
		@updated_count
	end
	
	def self.creature_maintenance
		#restore all creatures "being fought"
		@creatures = Creature.find(:all, :conditions => ['being_fought > 0'])
	
		@creatures = Creature.find(:all, :conditions => ['armed = true AND number_alive > 0'])
	end
	
#these are mostly jsut here for use by this class.
	def self.create_pandemic_notice(kingdom,text)
		#create kingdom notice of a player storming the gate
		@notice = KingdomNotice.new
		@notice.kingdom_id = kingdom.name
		@notice.shown_to = SpecialCode.get_code('shown_to','everyone')
		@notice.datetime = Time.now
		@notice.text = text
		@notice.signed = "Minister of Health and Sanitation"
		@notice.save
	end
	
	def self.create_pop_change_notice(kingdom,immigrants,emmigrants,births,disease)
		@notice = KingdomNotice.new
		@notice.kingdom_id = kingdom.name
		@notice.shown_to = SpecialCode.get_code('shown_to','everyone')
		@notice.datetime = Time.now
		@notice.text = "Population trends:<br/>Births: " + births.to_s +
																		 "<br/>Immigrants: " + immigrants.to_s +
																		 "<br/>Emmigrants: " + emmigrants.to_s +
																		 "<br/>Deaths from disease: " + disease.to_s
		@notice.signed = "Minister of Population"
		@notice.save
	end
end
