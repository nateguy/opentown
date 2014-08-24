class Polygon < ActiveRecord::Base
  belongs_to :plan
  has_many :vertices
end
