module Api
  module V1
    class ResetTransactionsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_request
      before_action :set_transaction, only: [:show]
      
      def index
        @transactions = ResetTransaction.includes(:user).order(created_at: :desc)
        render json: @transactions.as_json(include: { user: { only: [:id, :username, :first_name, :last_name] } })
      end
      
      def show
        render json: @transaction.as_json(include: { user: { only: [:id, :username, :first_name, :last_name] } })
      end
      
      def create
        # Find user if they exist in the system
        @user = User.find_by(username: params[:username])
        
        unless @user
          return render json: { error: 'User not found' }, status: :not_found
        end
        
        # Validate user information matches
        unless user_info_matches?(@user)
          return render json: { error: 'User information does not match our records' }, status: :unprocessable_entity
        end
        
        # Generate reset code
        reset_code = generate_reset_code(@user)
        
        @transaction = @user.reset_transactions.new(
          reset_code: reset_code,
          status: :active,
          location: params[:location],
          date_of_birth: params[:date_of_birth],
          sex: params[:sex]
        )
        
        if @transaction.save
          render json: {
            success: true,
            code: @transaction.formatted_reset_code,
            transaction: @transaction.as_json(include: { user: { only: [:id, :username, :first_name, :last_name] } })
          }, status: :created
        else
          render json: { error: @transaction.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def authenticate_api_request
        header = request.headers['Authorization']
        token = header.split(' ').last if header
        
        begin
          @decoded = JsonWebToken.decode(token)
          @current_user = User.find(@decoded[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          render json: { error: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { error: e.message }, status: :unauthorized
        end
      end
      
      def set_transaction
        @transaction = ResetTransaction.find(params[:id])
      end
      
      def user_info_matches?(user)
        user.first_name.downcase == params[:first_name].downcase &&
        user.last_name.downcase == params[:last_name].downcase
      end
      
      def generate_reset_code(user)
        # Create a unique identifier based on user data
        unique_id = "#{user.first_name[0..1]}#{user.last_name[0..1]}#{params[:date_of_birth].gsub('-', '')}#{params[:sex][0]}"
        
        # Add a random component and timestamp for uniqueness
        timestamp = Time.now.to_i.to_s(36)
        random_component = SecureRandom.alphanumeric(8).upcase
        
        # Combine everything to create a reset code
        "#{unique_id}#{timestamp}#{random_component}".upcase
      end
    end
  end
end

