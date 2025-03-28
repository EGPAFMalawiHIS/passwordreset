class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :register]

  # POST /auth/login
  def login
    command = AuthenticateUser.call(params[:username], params[:password])
    
    if command.success?
      render json: { 
        auth_token: command.result,
        user: UserSerializer.new(User.find_by(username: params[:username]))
      }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  # POST /auth/register
  def register
    @user = User.new(user_params)
    
    if @user.save
      command = AuthenticateUser.call(@user.username, params[:password])
      render json: { 
        auth_token: command.result,
        user: UserSerializer.new(@user)
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:username, :password, :first_name, :last_name)
  end

  class AuthenticateUser
    prepend SimpleCommand
    
    def initialize(username, password)
      @username = username
      @password = password
    end
    
    def call
      JsonWebToken.encode(user_id: user.id) if user
    end
    
    private
    
    attr_accessor :username, :password
    
    def user
      user = User.find_by(username: username)
      return user if user && user.authenticate(password)
      
      errors.add :user_authentication, 'Invalid credentials'
      nil
    end
  end
end

