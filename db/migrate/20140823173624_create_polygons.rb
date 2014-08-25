class CreatePolygons < ActiveRecord::Migration
  def change
    create_table :polygons do |t|
      t.belongs_to :plan
      t.belongs_to :zone
      t.string :type

      t.timestamps
    end
  end
end
