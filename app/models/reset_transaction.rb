class ResetTransaction < ApplicationRecord
  belongs_to :user
  
  validates :reset_code, presence: true
  validates :status, presence: true
  
  enum status: { active: 0, expired: 1, used: 2 }
  
  before_create :set_expiration
  
  scope :active, -> { where(status: :active) }
  scope :expired, -> { where(status: :expired) }
  scope :used, -> { where(status: :used) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :today, -> { where('created_at >= ?', Time.zone.now.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', Time.zone.now.beginning_of_week) }
  scope :this_month, -> { where('created_at >= ?', Time.zone.now.beginning_of_month) }
  
  def expired?
    expires_at < Time.current
  end
  
  def expire!
    update(status: :expired)
  end
  
  def formatted_reset_code
    reset_code.scan(/.{4}/).join('-')
  end
  
  def status_badge_class
    case status
    when 'active' then 'bg-success'
    when 'expired' then 'bg-danger'
    when 'used' then 'bg-info'
    else 'bg-secondary'
    end
  end
  
  private
  
  def set_expiration
    self.expires_at = 24.hours.from_now
  end
end

