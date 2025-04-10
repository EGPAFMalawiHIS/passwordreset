class User < ApplicationRecord
  has_secure_password
  
  has_many :password_resets, dependent: :destroy
  has_many :created_password_resets, class_name: 'PasswordReset', foreign_key: 'created_by_id'
  
  validates :username, presence: true, uniqueness: true
  validates :phone, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  validates :role, presence: true, inclusion: { in: %w(admin helpdesk user) }
  
  # Scopes
  scope :admins, -> { where(role: 'admin') }
  scope :helpdesk, -> { where(role: 'helpdesk') }
  scope :regular_users, -> { where(role: 'user') }
  
  # Returns the user's full name
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # Check if user is an admin
  def admin?
    role == 'admin'
  end
  
  # Check if user is a helpdesk officer
  def helpdesk?
    role == 'helpdesk' || role == 'admin'
  end
end