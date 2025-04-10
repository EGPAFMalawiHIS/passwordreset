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

  def search
    @pagy, @users = pagy(User.all, items: 10)
    render partial: 'users/user_list', locals: { users: @users }
  end

  def check_username
    username = params[:username]
    user = User.find_by(username: username)
    if user
      render json: { phone: user.phone[4..-1],firstname: user.first_name, lastname: user.last_name }
    else
      render json: { phone: nil }
    end
  end
  
end