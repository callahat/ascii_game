class RenameNameSurfixes < ActiveRecord::Migration
  def change
    rename_column :name_surfixes, :name_surfixes, :surfix
  end
end
