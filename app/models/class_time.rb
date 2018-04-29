class ClassTime < ApplicationRecord
  belongs_to :classRoom
  has_one :DayAndTimeOfClass
end
