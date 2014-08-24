class FixPolygonColumn < ActiveRecord::Migration
  def change
    rename_column :polygons, :type, :polygontype
  end
end
