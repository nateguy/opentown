class AddToDeleteColumnToPolygon < ActiveRecord::Migration
  def change
    add_column :polygons, :todelete, :booleon
  end
end
