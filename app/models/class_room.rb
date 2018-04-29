class ClassRoom < ApplicationRecord
  belongs_to :college
  has_many :classTimes
end
