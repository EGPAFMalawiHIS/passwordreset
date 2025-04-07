class PasswordResetsController < ApplicationController
  before_action :require_login
  before_action :require_helpdesk!
  before_action :set_password_reset, only: [:show]
  
  def index
    @pagy, @password_resets = pagy(PasswordReset.includes(:user)
                                    .order(created_at: :desc), 
                                    items: 15)
  end
  
  def new
    @password_reset = PasswordReset.new
  end
  
  def create
    # Find or create user, using password_digest method
    @user = User.find_by(username: params[:username])
    
    unless @user
      @user = User.new(
        username: params[:username],
        email: "#{params[:last_name]}@egpaf.org",
        first_name: params[:first_name],
        last_name: params[:last_name],
        role: 'user'
      )
      
      # Set a temporary password
      @user.password = SecureRandom.hex(8)
      @user.save!
    end
    
    # Find the location associated with the selected location_id
    location = Location.find_by(id: params[:location_id])
    
    unless location
      flash.now[:alert] = "Invalid location selected."
      render :new and return
    end

    # Generate password reset
    @password_reset = PasswordReset.create!(
      user: @user,
      created_by: current_user,
      reset_code: generate_reset_code(@user, location),
      status: 'active',
      expires_at: 24.hours.from_now,
      location: location.id
    )

    
    if @password_reset.save
      redirect_to password_resets_path, notice: 'Password reset code generated successfully'
    else
      flash.now[:alert] = @password_reset.errors.full_messages.join(', ')
      render :new
    end
  end
  
  def show
    # System overview statistics for sidebar
    @total_resets_today = PasswordReset.today.count
    @active_resets = PasswordReset.active.count
    @expired_resets = PasswordReset.where(status: 'expired').count
  end
  
  def search
    query = params[:q].to_s.strip
    
    @pagy, @password_resets = pagy(PasswordReset.joins(:user)
                                    .where("password_resets.code LIKE ? OR users.username LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ?", 
                                           "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
                                    .includes(:user)
                                    .order(created_at: :desc), 
                                    items: 15)
    
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @password_resets }
    end
  end
  
  private
  
  def set_password_reset
    @password_reset = PasswordReset.find(params[:id])
  end
  
  # Generate an encrypted reset code with user and location details
  def generate_reset_code(user, location)
    secret_key = "e4b9f7cbd6746f0d5a8b2479c3a2ea01a6dc6d9c09d63ffac8a6c17c00c2f4c7"
    # Prepare data to encrypt
    data = {
      firstname: user.first_name,
      lastname: user.last_name,
      username: user.username,
      location_uuid: location.uuid
    }

     code = EncryptionService.encrypt_to_code(data, secret_key)
     
     # Later, when decrypting:
     original_data = EncryptionService.decrypt_from_code(code, secret_key)    
     
     code
  end
  
end