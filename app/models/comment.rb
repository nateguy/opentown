class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :plan
  has_many :likes
end
