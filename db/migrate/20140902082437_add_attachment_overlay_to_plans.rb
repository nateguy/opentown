class AddAttachmentOverlayToPlans < ActiveRecord::Migration
  def self.up
    change_table :plans do |t|
      t.attachment :overlay
      t.float :sw_lat
      t.float :sw_lng
      t.float :ne_lat
      t.float :ne_lng
    end
  end

  def self.down
    remove_attachment :plans, :overlay
  end
end
