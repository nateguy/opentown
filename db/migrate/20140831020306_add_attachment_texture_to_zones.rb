class AddAttachmentTextureToZones < ActiveRecord::Migration
  def self.up
    change_table :zones do |t|
      t.attachment :texture
    end
  end

  def self.down
    remove_attachment :zones, :texture
  end
end
