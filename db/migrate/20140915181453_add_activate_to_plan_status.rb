class AddActivateToPlanStatus < ActiveRecord::Migration
  def change
    add_column :plan_statuses, :active, :boolean
  end
end
