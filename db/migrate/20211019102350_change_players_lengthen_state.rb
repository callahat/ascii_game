class ChangePlayersLengthenState < ActiveRecord::Migration
  def up
    change_column :players, :state, :string, limit: 32
  end

  def down
    change_column :players, :state, :string, limit: 2
  end
end
