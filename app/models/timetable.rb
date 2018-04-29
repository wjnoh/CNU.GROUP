class Timetable < ApplicationRecord
  belongs_to :user
  has_many :ttcells
end
