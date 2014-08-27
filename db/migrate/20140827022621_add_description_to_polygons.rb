class AddDescriptionToPolygons < ActiveRecord::Migration
  def change
    add_column :polygons, :description, :string
  end
end
