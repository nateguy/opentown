class CreateUserPolygons < ActiveRecord::Migration
  def change
    create_table :user_polygons do |t|
      t.belongs_to :user
      t.belongs_to :polygon
      t.integer :custom_zone
      t.string :custom_description
    end
  end
end
