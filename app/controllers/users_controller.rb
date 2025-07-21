class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update_password]
  before_action :require_login, except: [:new, :create, :forgot_password, :update_password]
  before_action :require_admin!, only: [:index, :show]
  
  layout 'auth', only: [:new]
  
  def index
  
        @pagy, @users = pagy(User.where.not(role: "user")
                                 .where.not(id: current_user.id)
                                 .order(:last_name, :first_name), items: 20)
  end
  
  def new
    @user = User.new
  end

  def forgot_password
       @users = {}

        User.where.not(role: "user").each do |user|
            @users[user.email] = {
                                     phone: user.phone,
                               maskedPhone: mask_phone(user.phone)
                            }
        end
  end

  def update_password
  begin
      
      @user = User.find_by(email: params[:email])
    if @user
      if @user.update(
        password: params[:password],
        password_confirmation: params[:password],
        active: true
      )
        render json: { 
          success: true, 
          message: "Password updated successfully" 
        }, status: :ok
      else
        render json: { 
          success: false, 
          message: @user.errors.full_messages.join(", ") 
        }, status: :unprocessable_entity
      end
    else
      render json: { 
        success: false, 
        message: "User not found" 
      }, status: :not_found
    end
  rescue => e
    render json: { 
      success: false, 
      message: "An error occurred: #{e.message}" 
    }, status: :internal_server_error
  end
  end

  def create
    @user = User.new(user_params)
    @user.role = 'helpdesk' # Default role for new users
    
    if @user.save
        if params[:redirect_to].present?
            redirect_to params[:redirect_to] || users_path, notice: "User was successfully created, Ask Administrator to activate your account!"
        elsif logged_in? && current_user.admin?
            redirect_to users_path, notice: "User was successfully created."
        else
            session[:user_id] = @user.id
           redirect_to dashboard_path, notice: "Account created successfully."
        end
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update(edit_user_params)
      redirect_to edit_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_activation
    @user = User.find(params[:id])
    
    if @user.update(active: !@user.active)
      flash[:notice] = "User #{@user.active? ? 'activated' : 'deactivated'} successfully"
    else
      flash[:alert] = "Failed to update user status"
    end
    
    redirect_to users_path
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

  def mask_phone(phone)
    return "" unless phone.present? && phone.length >= 10

    prefix = phone[0..3]  
    masked = '***'
    suffix = phone[-5..-1] 
    "#{prefix}#{masked}#{suffix}"
  end
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :phone, :email, :password, :password_confirmation)
  end

  def edit_user_params
    params.require(:user).permit(
      :first_name, 
      :last_name, 
      :username, 
      :phone
    )
  end
end