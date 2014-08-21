class Plan < ActiveRecord::Base
  has_many :polygons
  has_many :comments
end
