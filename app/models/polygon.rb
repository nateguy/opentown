class Polygon < ActiveRecord::Base
  belongs_to :plan
  belongs_to :zone
  has_many :vertices
end
