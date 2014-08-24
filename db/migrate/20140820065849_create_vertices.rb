class CreateVertices < ActiveRecord::Migration
  def change
    create_table :vertices do |t|
      t.belongs_to :polygon
      t.float :lat
      t.float :lng
      t.boolean :todelete
      t.timestamps
    end
  end
end
