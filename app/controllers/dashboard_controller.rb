class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @stats = {
      total_today: ResetTransaction.today.count,
      active_codes: ResetTransaction.active.count,
      expired_codes: ResetTransaction.expired.count
    }
    
    @recent_transactions = ResetTransaction.includes(:user).recent
  end
end

