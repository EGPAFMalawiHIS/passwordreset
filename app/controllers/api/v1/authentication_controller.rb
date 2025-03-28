module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :verify_authenticity_token
      
      def login
        user = User.find_by(username: params[:username])
        
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token, user: { id: user.id, username: user.username, name: user.full_name } }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end
    end
  end
end

