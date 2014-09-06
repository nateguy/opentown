class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :rating
      t.belongs_to :user
      t.belongs_to :plan
      t.timestamps
    end
  end
end