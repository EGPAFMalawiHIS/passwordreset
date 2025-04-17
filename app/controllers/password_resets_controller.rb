class PasswordResetsController < ApplicationController
  before_action :require_login
  before_action :require_helpdesk!
  before_action :set_password_reset, only: [:show]
  require 'open-uri'
  
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
    @user = User.find_by(username: params[:username],phone: params[:full_phone])
    phone = check_phone
    if phone && phone.username != params[:username]
      flash[:alert]  = "Phone already in use with user #{phone.username}"
      redirect_to controller: 'dashboard', action: 'index'
      return
    end

    unless @user
      @user = User.new(
        username: params[:username],
        email: "#{params[:last_name].downcase}#{params[:first_name][0].downcase}@egpaf.org",
        phone: params[:full_phone],
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
      flash[:alert]  = "Invalid location selected."
      redirect_to controller: 'dashboard', action: 'index'
      return
    end

    # Generate password reset
    @password_reset = PasswordReset.create!(
      user: @user,
      created_by: current_user,
      reset_code: generate_reset_code(@user, location),
      status: 'active',
      expires_at: 24.hours.from_now,
      location: location
    )

    
    if @password_reset.save
       flash[:notice]  = 'Password reset code generated successfully'
       redirect_to controller: 'dashboard', action: 'index'
       return
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

  def barcode_proxy
    url = params[:url]
    return head :bad_request unless url.present? && url.include?("barcode.tec-it.com")

    image = URI.open(url)
    send_data image.read, type: 'image/gif', disposition: 'inline'
  rescue => e
    Rails.logger.error "Barcode proxy error: #{e.message}"
    head :internal_server_error
  end
  
  private
  
  def set_password_reset
    @password_reset = PasswordReset.find(params[:id])
  end

  def check_phone
    phone = params[:full_phone]
    user = User.find_by(phone: phone)
  end
  
  # Generate an encrypted reset code with user and location details
  def generate_reset_code(user, location)
    secret_key = "CENTRALISED-EMR"
    # Prepare data to encrypt
    data = {
      firstname: user.first_name,
      lastname: user.last_name,
      username: user.username,
      location_id: location.location_id
  }

     code = EncryptionService.encrypt_to_code(data,secret_key)
     
     # Later, when decrypting:
     original_data = EncryptionService.decrypt_from_code(code, secret_key)    
     
     code
  end

  
  
end