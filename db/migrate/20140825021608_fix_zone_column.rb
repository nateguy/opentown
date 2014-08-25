class FixZoneColumn < ActiveRecord::Migration
  def change
    rename_column :zones, :class, :classification

  end
end
