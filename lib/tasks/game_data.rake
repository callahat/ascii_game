namespace :game_data do
  desc "This will update the XP reward for all creatures based on the built in XP value equation"
  task(:update_creature_xp=> :environment) do
    puts "\nUpdating all creatures XP"
    Creature.update_all_exps
    puts "\nDone updating all creatures XP."
  end  
end