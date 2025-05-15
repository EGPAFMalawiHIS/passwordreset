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

  def check_phone
     phone = params[:phone]

     phone = "+#{phone.gsub(/\s+/, '')}" unless phone.blank? || phone.start_with?('+')
     validation_result = validate_phone(phone)
     if validation_result[:error]
      return render json: { error: validation_result[:error] }, status: :unprocessable_entity 
     elsif validation_result[:username]
      return render json: { username: validation_result[:username] }
     end

      render json: { error: nil }
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

  private 

  def validate_phone(phone)
    if phone.blank?
      return { error: 'Phone number cannot be blank' }
    end
  
    # Check for valid format: +265 followed by 9 digits, not starting with 0
    unless phone.match?(/\A\+265[1-9]\d{8}\z/)
        return { error: 'Invalid phone number. Format should be +265 followed by 9 digits (not starting with 0)' }
    end
  
    if User.exists?(phone: phone)
      return { username: User.find_by(phone: phone).username }
    end
  
    { phone: nil }
  end
  
end