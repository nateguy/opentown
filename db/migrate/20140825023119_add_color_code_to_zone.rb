class AddColorCodeToZone < ActiveRecord::Migration
  def change
    add_column :zones, :color_code, :integer
  end
end
