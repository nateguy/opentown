class AddNeedAdminApprovalColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :need_admin_approval, :boolean
  end
end
