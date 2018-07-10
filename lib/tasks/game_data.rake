namespace :game_data do
  desc "This will update the XP reward for all creatures based on the built in XP value equation"
  task(:update_creature_xp=> :environment) do
    puts "\nUpdating all creatures XP"
    Creature.update_all_exps
    puts "\nDone updating all creatures XP."
  end

  desc "This will check map coordinates for no feature and inject the empty feature"
  task(fill_in_empty_map_spaces: :environment) do
    puts "\nReplacing nil map locations with the empty feature"
    @empty_feature = Feature.find_by(name: "Empty", kingdom_id: -1, player_id: -1)

    puts "Checking Kingdom Maps"
    Level.all.each do |level|
      0.upto(level.maxy-1) do |y|
        0.upto(level.maxx-1) do |x|
          if level.level_maps.where(ypos: y, xpos: x).count == 0
            puts "row #{y} col #{x} no feature"
            level.level_maps.create!(ypos: y, xpos: x, feature: @empty_feature)
          elsif level.level_maps.where(ypos: y, xpos: x).last.feature_id.nil?
            puts "row #{y} col #{x} active feature is nil"
            level.level_maps.where(ypos: y, xpos: x).last.update_attributes! feature_id: @empty_feature.id
          elsif level.level_maps.exists?(ypos: y, xpos: x, feature_id: nil)
            puts "row #{y} col #{x} feature is nil"
            level.level_maps.where(ypos: y, xpos: x, feature_id: nil).each do |lm|
              lm.update_attributes! feature_id: @empty_feature.id
            end
          end
        end
      end
    end

    puts "Checking World Maps"
    World.all.each do |world|
      world.minbigx.upto(world.maxbigx) do |bigx|
        world.minbigy.upto(world.maxbigy) do |bigy|
          if world.world_maps.exists?(bigxpos: bigx, bigypos: bigy)
            1.upto(world.maxy) do |y|
              1.upto(world.maxx) do |x|
                if world.world_maps.where(bigxpos: bigx, bigypos: bigy, ypos: y, xpos: x).count == 0
                  puts "row #{y} col #{x} no feature"
                  world.world_maps.create!(bigxpos: bigx, bigypos: bigy, ypos: y, xpos: x, feature: @empty_feature)
                elsif world.world_maps.where(bigxpos: bigx, bigypos: bigy, ypos: y, xpos: x).last.feature_id.nil?
                  puts "row #{y} col #{x} active feature is nil"
                  world.world_maps.where(bigxpos: bigx, bigypos: bigy, ypos: y, xpos: x).last.update_attributes! feature_id: @empty_feature.id
                elsif world.world_maps.exists?(bigxpos: bigx, bigypos: bigy, ypos: y, xpos: x, feature_id: nil)
                  puts "row #{y} col #{x} feature is nil"
                  world.world_maps.where(bigxpos: bigx, bigypos: bigy, ypos: y, xpos: x, feature_id: nil).each do |wm|
                    wm.update_attributes! feature_id: @empty_feature.id
                  end
                end
              end
            end
          end
        end
      end
    end

    puts "\nDone."
  end

  desc "Cleans up feature events that have no feature and/or event"
  task(cleanup_feature_events: :environment) do
    puts "Checking for invalid events..."
    FeatureEvent.all.each do |fe|
      if fe.event.nil?
        puts "#{fe.id} has an event_id, but the event does not exist; deleting"
        fe.destroy
      elsif fe.feature.nil?
        puts "#{fe.id} has a feature_id, but the feature does not exist; deleting"
        fe.destroy
      end
    end
    puts "Done."
  end
end