class Board < ApplicationRecord
  has_many :posts
  has_many :applies
  has_many :accept_applies

end
