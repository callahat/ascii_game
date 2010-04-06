namespace :maintenance do
	desc "This will run the nightly maintenance on all stuff, run this instead of the other two"
	task(:full_maintenance => :environment) do
		puts "\nTime is now: " + Time.now.to_s
		puts "\nRunning the nightly kingdom maintenance, bringing down system  . . ."
		@start = Time.now
		SystemStatus.stop(1)
		Maintenance.clear_report
		Maintenance.kingdom_maintenance
		Maintenance.player_character_maintenance
		puts Maintenance.report.join("\n")
		puts "\n\n" + (Time.now - @start).to_s + " elapsed seconds.\n"
		puts "\nNightly kingdom maintenance complete, bringing up system  . . ."
		SystemStatus.start(1)
	end

	desc "This will run the nightly kingdom maintenance"
	task(:kingdom_maintenance => :environment) do
		puts "\nRunning the nightly kingdom maintenance, bringing down system  . . ."
		SystemStatus.stop(1)
		Maintenance.clear_report
		Maintenance.kingdom_maintenance
		puts Maintenance.report.join("\n")
		puts "\nNightly kingdom maintenance complete, bringing up system  . . ."
		SystemStatus.start(1)
	end
  
	desc "This will run the nightly player character maintenance"
	task(:player_character_maintenance => :environment) do
		puts "\nRunning the nightly player character maintenance, bringing down system . . ."
		SystemStatus.stop(1)
		Maintenance.clear_report
		Maintenance.player_character_maintenance
		puts Maintenance.report.join("\n")
		puts "\nNightly player character maintenance complete, bringing up system  . . ."
		SystemStatus.start(1)
	end

  desc "This will remove a kingdom from the database, including all rows directly associated with it (ie, events). Use with caution."
  task(:nuke_kingdom => :environment) do
    #break
    puts RAILS_ENV
    puts "Enter kingdom number:"
    x = STDIN.gets
    kingdom=Kingdom.find_first(:id => x)
    if kingdom.nil?
      puts "\nNo kingdom found with that number."
    elsif x.to_i <= 0
      puts "\nKingdom 0 and -1 may not be deleted"
    else
      puts "\nKingdom found"
      wipe_kingdom(kingdom)
    end
  end
  
  desc "This wipes all the kingdom data, except for kingdom -1 and 0."
  task(:nuke_all_kingdom_data => :environment) do
    puts "wiping all done events, done quests"
    nuke_array(DoneEvent.find_all)
    nuke_array(DoneQuest.find_all)
  
    kingdoms=Kingdom.find(:all, :conditions => ['id > 0'])
    for kingdom in kingdoms do
      puts "***************************************"
      puts "Wiping " + kingdom.name
      wipe_kingdom(kingdom)
    end
    
    puts "\nDone"
  end
  
  desc "This wipes all player data, boards, forums, pc's, player accounts, etc"
  task(:nuke_all_player_data => :environment) do
    puts "Are you sure motherfucker?"
    x = STDIN.gets

    puts x[0]
    puts "Y"[0]
    if x[0] == "Y"[0]
      puts "Wiping all player data"
      puts "Destroying done events"
      nuke_array(DoneEvent.find_all)
      puts "Destroying done quests"
      nuke_array(DoneQuest.find_all)
      puts "Destroying Genocides"
      nuke_array(Genocide.find_all)
      puts "Destroying creature kills"
      nuke_array(CreatureKill.find_all)
      puts "Destroying infections"
      nuke_array(Infection.find_all)
      puts "Destroying kingdom bans"
      nuke_array(KingdomBan.find_all)
      puts "Destroying log quests"
      for log in LogQuest.find_all
        nuke_array(log.all_logs)
        log.destroy
      end
      puts "Destroying posts, threads, and boards"
      nuke_array(Post.find_all)
      nuke_array(Thred.find_all)
      nuke_array(Board.find_all)
      puts "Destroying quest kill PCs, PC events"
      nuke_array(QuestKillPc.find_all)
      nuke_array(EventPlayerCharacter.find_all)
      puts "Dethroning all PCs"
      for kingdom in Kingdom.find_all
        kingdom.player_character_id = nil
        kingdom.update
      end
      puts "Destroying player characters"
      nuke_array(PlayerCharacterEquipLoc.find_all)
      nuke_array(PlayerCharacterItem.find_all)
      nuke_array(PlayerCharacterKiller.find_all)
      nuke_array(NonplayerCharacterKiller.find_all)
      nuke_array(PlayerCharacterEquipLoc.find_all)
      nuke_array(PlayerCharacter.find_all)
      puts "Dissassociating player from creature created"
      for c in Creature.find_all
        c.player_id = 0
        c.update
      end
      puts "Dissassociating player from event created"
      for e in Event.find_all
        e.player_id = 0
        e.update
      end
      puts "Dissassociating player from feature created"
      for f in Feature.find_all
        f.player_id = 0
        f.update
      end
      puts "Dissassociating player from image created"
      for i in Image.find_all
        i.player_id = 0
        i.update
      end
      puts "Dissassociating player from quests created"
      for q in Quest.find_all
        q.player_id = 0
        q.update
      end
      puts "Destroying players"
      nuke_array(Player.find(:all, :conditions => ['id > 1']))
    else
      puts "...pussy"
    end
  end
  
  #function that does actual kingdom wiping
  def wipe_kingdom(kingdom)
    #go about removing it and its associated stuff.
    puts "Dissassociating races:"
    for race in kingdom.races
      puts "Dissassociating the race: " + race.name
      race.kingdom_id = 0
      race.update
    end
    
    puts "Dissassociating creatures"
    for c in kingdom.creatures
      puts "Dissassociating the creature: " + c.name
      c.kingdom_id = 0
      c.update
    end
    
    puts "kicking out player characters"
    for pc in PlayerCharacter.find_all(:in_kingdom => kingdom.id)
      pc.kingdom_level = nil
      pc.in_kingdom = nil
      pc.update
    end
    
    puts "dehoming allied NPC's"
    for npc in kingdom.npcs
      npc.kingdom_id = nil
      npc.update
    end
    
    puts "dehoming allied PC's"
    for pc in kingdom.player_characters
      pc.kingdom_id = 0
      pc.update
    end
    
    puts "Destroying empty shops"
    nuke_array(kingdom.kingdom_empty_shops)
    
    puts "Destroying quests and quest logs and done quests"
    for quest in kingdom.quests
      quest.quest_id = nil  #eliminate all prereqs
      quest.update
    end
    for quest in kingdom.quests
      @logs = quest.log_quests
      for log in @logs
        nuke_array(log.all_logs)
        log.destroy
      end
      nuke_array(quest.all_reqs)
      nuke_array(quest.done_quests)
      quest.destroy
    end
    
    puts "Abandoning features and destroying feature events"
    @features = []
    @features << kingdom.all_features.find(:all, :conditions => ['public = false OR armed = false'])
    puts "Destroying castle feature"
    @features << Feature.find_first(:name => "\nCastle #{kingdom.name}")
    puts "Destroying the throne feature"
    @features << Feature.find_first(:name => "\nThrone #{kingdom.name}")
    puts "Destroying worldmap entrance feature and world map tile"
    @features << Feature.find_first(:name => "\nKingdom #{kingdom.name} entrance")
    @features.flatten!.delete(nil)
    
    for feature in @features
      nuke_array(feature.feature_events)
      nuke_array(feature.level_maps)
      for wm in feature.world_maps
        nuke_array(wm.done_events)
        wm.destroy
      end
      feature.kingdom_id = 0
      feature.update
    end
    
    puts "Dissassociating public features"
    for feature in kingdom.features do
      feature.kingdom_id = 0
      feature.update
    end
    
    puts "Destroy sub events and done events"
    for event in kingdom.events
      nuke_array(event.done_events)
      nuke_array(event.event_subs)
      nuke_array(event.feature_events)
      nuke_array(event.quest_explores)
      event.destroy
    end
    
    puts "Destroying the castle event"
    if @e=Event.find_first(:name => "\nCastle #{kingdom.name} event")
      nuke_array(@e.done_events)
      nuke_array(@e.event_subs)
      @e.destroy
    end
    
    puts "Destroying the throne event"
    if @e=Event.find_first(:name => "\nThrone #{kingdom.name} event")
      nuke_array(@e.done_events)
      nuke_array(@e.event_subs)
      nuke_array(@e.feature_events) #just in case the throne doesnt have a specific feature
      @e.destroy
    end
    
    puts "Destroying the entrance event"
    if @event = Event.find_first(:name => "\nKingdom #{kingdom.name} entrance")
      nuke_array(@event.done_events)
      nuke_array(@event.event_subs)
      @event.destroy
    end
    
    puts "Destroying the storm gate event"
    if @event = Event.find_first(:name => "\nKingdom #{kingdom.name} storm event")
      nuke_array(@event.done_events)
      nuke_array(@event.event_subs)
      @event.destroy
    end
    
    puts "Destroying levels, remaining level maps"
    for level in kingdom.levels
      for level_map in level.level_maps
        level_map.destroy
      end
      level.destroy
    end
    
    puts "Destroing pandemics"
    nuke_array(kingdom.pandemics)
    
    puts "Dissassociating NPCS"
    @def_npc_image = Image.find_first(:name => "DEFAULT NPC")
    for npc in kingdom.npcs
      npc.kingdom_id = nil
      npc.is_hired = false
      npc.image_id = @def_npc_image.id
    end
    
    puts "Dissasociating images"
    for image in kingdom.images
      image.kingdom_id = 0
      image.update
    end
    
    puts "Destroying Bans"
    nuke_array(kingdom.kingdom_bans)
    
    puts "Destroying kingdom entries"
    if @k=kingdom.kingdom_entry
      @k.destroy
    end
    
    puts "Destroying notices"
    nuke_array(kingdom.kingdom_notices)
    
    puts "Destroying kingdom items"
    nuke_array(kingdom.kingdom_items)
    
    puts "Destroying pref lists"
    nuke_array(kingdom.pref_lists)
    
    puts "Dissassociating quest kill npcs"
    for q in kingdom.quest_kill_n_npcs
      q.kingdom_id = 0
      q.update
    end
    
    puts "That should be everything deleted or dissassociated. Deleting kingdom"
    kingdom.destroy
  end
  
  #just a function to destroy all the elements of an array
  def nuke_array(array)
    for a in array
      a.destroy
    end
  end
  
end