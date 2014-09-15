class PlanStatus < ActiveRecord::Base
  belongs_to :plan
  belongs_to :status
end
