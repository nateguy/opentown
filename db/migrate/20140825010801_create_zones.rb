class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.string :code
      t.string :description
      t.string :class
      t.timestamps
    end

  end
end
