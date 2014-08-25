class AddZoneToPolygon < ActiveRecord::Migration
  def change
    add_column :polygons, :zone_id, :integer
  end
end
