class ChangeZoneColumnType < ActiveRecord::Migration
  def change
    change_column :zones, :color_code, :string
  end
end
