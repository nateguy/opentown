class Status < ActiveRecord::Base
  has_many :plan_statuses
end
