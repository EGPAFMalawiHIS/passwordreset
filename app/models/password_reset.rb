class PasswordReset < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: 'User'
  belongs_to :location, optional: true

  validates :reset_code, presence: true, uniqueness: false
  validates :status, inclusion: { in: ['active', 'used', 'expired'] }
  validate :code_expiration

  before_validation :set_status
  before_validation :generate_unique_code, on: :create

  # Scopes
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :active, -> { where(status: 'active').where('expires_at > ?', Time.current) }
  scope :expired, -> { where(status: 'expired').or(where('expires_at <= ?', Time.current)) }
  scope :used, -> { where(status: 'used') }

  def generate_code(first_name:, last_name:)
    # Generate a unique reset code
    self.reset_code = loop do
      random_code = SecureRandom.hex(8).upcase
      break random_code unless PasswordReset.exists?(reset_code: random_code)
    end

    # Set expiration
    self.expires_at ||= 24.hours.from_now
    self
  end

  def generate_unique_code
    self.reset_code ||= loop do
      random_code = SecureRandom.hex(8).upcase
      break random_code unless self.class.exists?(reset_code: random_code)
    end
  end

  def active?
    status == 'active' && expires_at > Time.current
  end

  def expired?
    status == 'expired' || expires_at <= Time.current
  end

  def valid_reset?
    status == 'active' && expires_at > Time.current
  end

  def mark_as_used!
    update(status: 'used')
  end

  def mark_as_expired!
    update(status: 'expired')
  end

  private

  def set_status
    self.status ||= 'active'
    
    if expires_at && expires_at <= Time.current
      self.status = 'expired'
    end
  end

  def code_expiration
    if expires_at && expires_at <= Time.current
      errors.add(:base, "Reset code has expired")
    end
  end
end