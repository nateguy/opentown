class UserPolygon < ActiveRecord::Base
  belongs_to :user
  belongs_to :polygon

end