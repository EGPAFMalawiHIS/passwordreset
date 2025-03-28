module JwtAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Unauthorized' }, status: 401 unless @current_user
  end

  class AuthorizeApiRequest
    def self.call(headers = {})
      new(headers).call
    end
    
    def initialize(headers = {})
      @headers = headers
    end
    
    def call
      {
        result: user
      }
    end
    
    private
    
    attr_reader :headers
    
    def user
      @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    rescue ActiveRecord::RecordNotFound
      nil
    end
    
    def decoded_auth_token
      @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
    end
    
    def http_auth_header
      if headers['Authorization'].present?
        return headers['Authorization'].split(' ').last
      end
      nil
    end
  end
end

