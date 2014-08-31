class Zone < ActiveRecord::Base
  has_many :polygons
  has_attached_file :texture, :styles => { :medium => "100x100", :thumb => "100x100" }
  validates_attachment_content_type :texture, :content_type => /\Aimage\/.*\Z/
end
