class Suggestionpost < ApplicationRecord
  belongs_to :user
  has_many :replies
end
