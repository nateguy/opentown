class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.belongs_to :user
      t.belongs_to :comment
      t.boolean :like

      t.timestamps
    end
  end
end
