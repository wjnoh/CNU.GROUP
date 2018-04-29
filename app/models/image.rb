class Image < ApplicationRecord
  mount_uploader :file, StorageUploader
end
