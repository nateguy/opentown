class CreatePolygons < ActiveRecord::Migration
  def change
    create_table :polygons do |t|
      t.belongs_to :plan
      t.string :type

      t.timestamps
    end
  end
end
