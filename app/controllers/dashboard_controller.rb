class DashboardController < ApplicationController
  before_action :require_login
  before_action :require_helpdesk!
  
  def index
    # System overview statistics
    @total_resets_today = PasswordReset.today.count
    @active_resets = PasswordReset.active.count
    @expired_resets = PasswordReset.where(status: 'expired').count
    
    # Recent transactions
    @recent_resets = PasswordReset.includes(:user)
                                  .order(created_at: :desc)
                                  .limit(5)
  end
end