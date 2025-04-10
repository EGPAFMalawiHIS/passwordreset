class Location < ApplicationRecord
  has_many :password_resets, dependent: :destroy
  has_many :users, through: :password_resets
end
