class AddSystemGeneratedColumnToFeaturesAndEvents < ActiveRecord::Migration
  def up
    add_column :features, :system_generated, :boolean, default: false
    add_column :events,   :system_generated, :boolean, default: false

    say_with_time 'Updating Feature records' do
      features = Feature.arel_table
      Feature.where(features[:name].matches("\n%")).each do |feature|
        feature.system_generated = true unless feature.name == "\nEmpty"
        feature.name = feature.name[1..-1]
        feature.save!
      end
    end
    say_with_time 'Updating Event records' do
      events = Event.arel_table
      Event.where(events[:name].matches("\n%")).each do |event|
        event.system_generated = true unless event.name == "\nEmpty"
        event.name = event.name[1..-1]
        event.save!
      end
    end
  end

  def down
    say_with_time 'Rolling back Feature records' do
      Feature.where(system_generated: true).each do |feature|
        feature.name = "\n" + feature.name
        feature.save!
      end
    end
    say_with_time 'Rolling back Event records' do
      Event.where(system_generated: true).each do |event|
        event.name = "\n" + event.name
        event.save!
      end
    end

    remove_column :features, :system_generated
    remove_column :events,   :system_generated

    say 'Do not forget to update the Empty feature name if necessary'
  end
end
