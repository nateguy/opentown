class AddPlanBody < ActiveRecord::Migration
  def change
    add_column :plans, :content, :text
  end
end
