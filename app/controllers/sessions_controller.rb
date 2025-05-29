class SessionsController < ApplicationController
  layout 'auth'
  
  def new
    redirect_to dashboard_path if logged_in?
  end
  
  def create
    user = User.find_by(username: params[:username])
    
    if user && user.authenticate(params[:password])
      if user.can_login?
        session[:user_id] = user.id
        redirect_to dashboard_path, notice: "Logged in successfully!"
      else
        flash.now[:alert] = "Your account is inactive. Please contact an administrator."
        render :new
      end
    else
      flash.now[:alert] = 'Invalid username or password'
      render :new
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Logged out successfully'
  end
end