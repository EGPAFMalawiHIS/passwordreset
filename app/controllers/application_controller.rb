class ApplicationController < ActionController::Base
  include Pagy::Backend

  protect_from_forgery with: :exception
  
  helper_method :current_user, :logged_in?
  
  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end

  def check_phone
    phone = params[:phone]
    user = User.find_by(phone: phone)
    
    if user
      render json: { username: user.username }
    else
      render json: { username: nil }
    end
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
  
  def require_admin!
    unless current_user&.admin?
      flash[:alert] = "You don't have permission to access this section"
      redirect_to root_path
    end
  end
  
  def require_helpdesk!
    unless current_user&.helpdesk?
      flash[:alert] = "You don't have permission to access this section"
      redirect_to root_path
    end
  end
end