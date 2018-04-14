class BackconfirmAlreadyExistingUsers < ActiveRecord::Migration
  def up
    Player.all.find_in_batches do |groups|
      groups.each do |player|
        player.update_attribute :confirmed_at, Time.now
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
