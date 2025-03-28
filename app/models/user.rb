class User < ApplicationRecord
  has_secure_password
  has_many :reset_transactions, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: true, length: { minimum: 8 }, if: :password_digest_changed?
  
  def full_name
    "#{first_name} #{last_name}"
  end
end

