class ApplicationController < ActionController::Base
  include Pagy::Backend
  
  helper_method :current_user, :logged_in?
  
  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def authenticate_user!
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end
end

