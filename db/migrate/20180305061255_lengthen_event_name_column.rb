class LengthenEventNameColumn < ActiveRecord::Migration
  def change
    change_column :events, :name, :string, :limit => 64
  end
end
