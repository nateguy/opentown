class Plan < ActiveRecord::Base
  has_many :polygons
  has_many :comments
  has_many :ratings
  has_attached_file :overlay, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :overlay, :content_type => /\Aimage\/.*\Z/
end
