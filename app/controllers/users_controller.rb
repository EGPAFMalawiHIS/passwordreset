class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :require_admin!, only: [:index, :show]
  
  layout 'auth', only: [:new]
  
  def index
    @pagy, @users = pagy(User.order(:last_name, :first_name), items: 20)
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    @user.role = 'helpdesk' # Default role for new users
    
    if @user.save
      if logged_in? && current_user.admin?
        redirect_to users_path, notice: "User was successfully created."
      else
        session[:user_id] = @user.id
        redirect_to dashboard_path, notice: "Account created successfully."
      end
    else
      render :new
    end
  end
  
  def show
    @user = User.find(params[:id])
    @password_resets = @user.password_resets.order(created_at: :desc).limit(10)
  end
  
  def search
    query = params[:q].to_s.strip
    
    @pagy, @users = pagy(User.where("username LIKE ? OR email LIKE ? OR first_name LIKE ? OR last_name LIKE ?", 
                        "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
                .order(:last_name, :first_name), 
                items: 20)
    
    render :index
  end
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end
end