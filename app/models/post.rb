class Post < ApplicationRecord
  belongs_to :user
  belongs_to :board
  has_many :replies

  mount_uploader :modifyFileName, StorageUploader
end
