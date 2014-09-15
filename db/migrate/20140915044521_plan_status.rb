class PlanStatus < ActiveRecord::Migration
  def change
    create_table :plan_statuses do |t|
      t.belongs_to :plan
      t.belongs_to :status
      t.integer :stage
      t.datetime :effect_date
      t.timestamps
    end
  end
end
