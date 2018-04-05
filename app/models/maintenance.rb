class Maintenance < ActiveRecord::Base
  #Don't use these methods if the system is running.
  #This will be an honor system enforcement
  #Use the maintenance scripts instead of calling these individually.

  @@report = []

  def self.report
    @@report
  end

  def self.clear_report
    @@report = []
  end

  #Allocate NPCs/create NPCs and assign to existing kingdom
  def self.new_kingdom_npcs(kingdom)
    @@report << "NEW KINGDOM NPCS FOR " + kingdom.name
    kingdom.npcs.where(is_hired: 0).each{
      |uh| uh.update_attribute(:kingdom_id, nil) if rand > 0.75 }

    @unhired_merchants = kingdom.merchants.where(is_hired: 0)
    @unhired_guards = kingdom.guards.where(is_hired: 0)

    if @unhired_merchants.size < kingdom.kingdom_empty_shops.size * 1.5
      npc_solicitation(kingdom, NpcMerchant)
    end
    npc_solicitation(kingdom, NpcGuard) if kingdom.player_character
  end

  def self.npc_solicitation(kingdom, npc_class)
    if @unhired_merchants.size < kingdom.player_character.level * 2

      @npc_from_pool = npc_class.order('rand()').find_by(kingdom_id: nil)

      if @npc_from_pool.nil? || rand > 0.75
        @new_guy = npc_class.generate(kingdom.id)

        @@report << @new_guy.name + " entered the job market"
      else
        @npc_from_pool.update_attribute(:kingdom_id, kingdom.id)
        @@report << @npc_from_pool.name + " is looking for employment"
      end
    end
  end

  #NPCs gain stat bonuses
  #Blacksmiths check to see if they can make a new item
  #NPC's gain some stat gains
  #NPCs HP and MP restored, unless they have a disease fatal to NPCs
  #NPC's take damage from infections
  def self.kingdom_npcs_maintenance(kingdom, npcs)
    for npc in npcs
      #get the disease damage toll first
      @disease_damage = npc.illnesses.inject(0){|c,i| c+i.disease.HP_per_turn }

      #lock NPC, just to be safe
      Npc.transaction do
        begin
        npc.lock! && npc.stat.lock! && npc.health.lock!

        Stat.symbols.each{|sym| npc.stat[sym] += rand(4) }
        npc.gold = rand(500)
        npc.experience += rand(50)
        npc.health.base_HP += rand(7)
        npc.health.HP += npc.health.base_HP - @disease_damage

        @terminal_diseases = npc.illnesses.joins(:disease).where(diseases: {NPC_fatal: true})
        if @terminal_diseases.size > 0
          if npc.health.HP <= 0
            npc.health.wellness = SpecialCode.get_code('wellness','dead')
            KingdomNotice.create_notice(
                npc.name + " died from " + @terminal_diseases.rand.disease.name + ".",
                kingdom.id,
                "Minister of Health and Sanitation")
          end
        else
          npc.health.HP = [npc.health.HP,1].max
        end
        npc.save! && npc.stat.save! && npc.health.save!
        rescue Exception => e
          @@report << e
        end
      end

      if npc.health.wellness == SpecialCode.get_code('wellness','dead')
        @@report << "This is a dead NPC :'("
      else
        if npc.kind_of?(NpcMerchant) and npc.npc_merchant_detail
          if npc.npc_merchant_detail.healing_sales.to_i > 0
            #can any pandemics be cured?
            for pandemic in kingdom.pandemics
              if HealerSkill.where(disease_id: pandemic.disease_id) \
                     .find_by('min_sales <= ?', npc.npc_merchant_detail.healing_sales) &&
                  rand(pandemic.disease.virility) < npc.int / 10  #then NPC has cured the pandemic
                text = npc.name + " has discovered a cure for the " + pandemic.disease.name +
                       " pandemic which had been tormenting the kingdom for " + pandemic.day + " days."
                KingdomNotice.create_notice(text, kingdom.id, "Minister of Health and Sanitation")
                pandemic.destroy
              end
            end
          end
          if npc.npc_merchant_detail.blacksmith_sales.to_i > 0
            NpcBlacksmithItem.gen_blacksmith_items(npc, npc.npc_merchant_detail.blacksmith_sales, rand(1))
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
    @dead_from_disease = 0
    for pandemic in kingdom.pandemics
      #npc catch?
      pandemic.day += 1
      pandemic.save

      #only airbourne can be spread
      if pandemic.disease.trans_method == SpecialCode.get_code('trans_method','air')
        npcs.each{|npc| Illness.infect(npc, pandemic.disease) }
      end

      Kingdom.transaction do
        kingdom.lock!

        if kingdom.num_peasants < pandemic.disease.min_peasants
          #not enough peasants, pandemic ends
          text = "The number of cases of " + pandemic.disease.name + " has greatly diminished, ending the " +
                  pandemic.day.to_s + " pandemic."
          KingdomNotice.create_notice(text, kingdom.id, "Minister of Health and Sanitation")
          pandemic.destroy
        else
          @fatality = pandemic.disease.peasant_fatality
          @fatality = @fatality / 2.0 + rand(@fatality / 2.0)
          @deaths = (kingdom.num_peasants * (@fatality / 100.0)).to_i

          @dead_from_disease += @deaths

          #notice for deaths
          text = @deaths.to_s + " peasants died from " + pandemic.disease.name
          KingdomNotice.create_notice(text, kingdom.id, "Minister of Health and Sanitation")
          kingdom.num_peasants -= @deaths
        end

        kingdom.save!
      end
    end
    return @dead_from_disease
  end

  #main routine to take care of all the kingdom maintenance that needs done
  def self.kingdom_maintenance
    @kingdoms = Kingdom.where('id > 0')
    @updates = 0
    for kingdom in @kingdoms
      @@report << "Maintenance for " + kingdom.name

      @npcs = kingdom.live_npcs
      @disease_deaths = kingdom_pandemics(kingdom, @npcs)
      kingdom_npcs_maintenance(kingdom, @npcs)

      #taxes and new peasants
      Kingdom.transaction do
        kingdom.lock!

        @current_pop = kingdom.num_peasants
        @tax_revenue = (kingdom.num_peasants * kingdom.tax_rate / 1000.0).to_i
        @immigrants = 3 + (100 - (kingdom.tax_rate ** 2) / 100.0).to_i
        @immigrants *= [(kingdom.housing_cap - kingdom.num_peasants - @immigrants), 1].min
        @immigrants = 0 if @immigrants < 0
        @emmigrants = [30+kingdom.housing_cap - kingdom.num_peasants, 0].min
        @emmigrants /= (rand(10)+1) unless @emmigrants < kingdom.housing_cap * -2
        @births = ((rand(10) + kingdom.num_peasants + @emmigrants) * [100 - kingdom.tax_rate ** 2, 1].max / 1000.0).to_i

        kingdom.num_peasants += @births + @immigrants + @emmigrants
        kingdom.gold += @tax_revenue

        text = "Population trends:" +
               "%-26s%20s" % ["<br/>Last Population:" ,@current_pop] +
               "%-26s%20s" % ["<br/>Current Population:" ,kingdom.num_peasants] +
               "%-26s%20s" % ["<br/>Births:", @births.to_s] +
               "%-26s%20s" % ["<br/>Immigrants:", @immigrants.to_s] +
               "%-26s%20s" % ["<br/>Emmigrants:", (-1*@emmigrants).to_s] +
               "%-26s%20s" % ["<br/>Deaths from disease:", @disease_deaths.to_s]
        KingdomNotice.create_notice(text, kingdom.id, "Minister of Population")

        kingdom.save!
      end

      @@report << "\nPopulation trends:" +
                  "%-26s%20s" % ["\nCurrent Population:" ,@current_pop.to_s] +
                  "%-26s%20s" % ["\nBirths:", @births.to_s] +
                  "%-26s%20s" % ["\nImmigrants:", @immigrants.to_s] +
                  "%-26s%20s" % ["\nEmmigrants:", (-1*@emmigrants).to_s] +
                  "%-26s%20s" % ["\nDeaths from disease:", @disease_deaths.to_s]

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
    #add turns for player characters that are active only, and have used turns since last time
    @player_characters = PlayerCharacter.where(char_stat: SpecialCode.get_code('char_stat','active')).where('turns < 200')
    @updated_count = 0
    for pc in @player_characters
      begin
      #might as well get the lock
      PlayerCharacter.transaction do
        @@report << "Updating PC #" + pc.id.to_s + " " + pc.name

        pc.lock!
        turns_added = ( pc.turns > 160 ? 200 - pc.turns : 40 )
        pc.turns += turns_added
        pc.save!

        @@report << " gained " + turns_added.to_s + " turns."

        pc.health.lock!
        #if not alive, no point in damage from disease and checking to see if it killed themz
        if pc.health.wellness == SpecialCode.get_code('wellness','alive')
          for infection in pc.illnesses   #take health away at end of day, ratehr than for every turn
            #future thing to add: see if the pc has th constitution to just immunize to the disease
            pc.health.HP -= infection.disease.HP_per_turn
            pc.health.MP -= infection.disease.MP_per_turn
            @@report << infection.disease.name + " causes " + infection.disease.HP_per_turn.to_s + " HP, " + infection.disease.MP_per_turn.to_s + " MP damage."
          end
          #see if PC still alive.
          if pc.health.HP <= 0
            pc.health.wellness = SpecialCode.get_code('wellness','dead')
            @@report << " Died from untreated disease."
          end
        end
        pc.health.save!
      end
      @updated_count += 1
      rescue Exception => e
        @@report << e
      end
    end
    @updated_count
  end

  def self.creature_maintenance
    @@report << "Creature maintenance"
    Creature.where(armed: true).where('being_fought > 0').each{|c|
    begin
      c.lock!
      c.number_alive += c.being_fought
      @@report << "  shifted " + c.being_fought.to_s + " " + c.name + " from being fought to alive; total alive now:" + c.number_alive.to_s
      c.save!
    rescue Exception => e
     @@report << e
    end }
  end
end
