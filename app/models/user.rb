class User < ApplicationRecord
  has_many :posts
  has_many :replies
  has_many :boards
  has_many :applies
  has_many :accept_applies
  has_many :notices
  has_many :timetables

  has_many :freeposts
  has_many :adposts
  has_many :suggestionposts

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #,:confirmable

# 가입할 때 비어있으면 에러
validates :name, presence: true, on: :create
validates :studentid, presence: true, on: :create
validates :gender, presence: true, on: :create

end
