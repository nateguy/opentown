class CreatePolygons < ActiveRecord::Migration
  def change
    create_table :polygons do |t|
      t.belongs_to :plan
      t.float :lat
      t.float :lng
      t.timestamps
    end
  end
end
