require "base64" 
require "json"
module SsoClient
  class UserLoggedSessionHandler
    SSO_KEY = :sso_token
    TOKEN_VALUE_KEY = "token_secret"
    TOKEN_EXPIRATION_DATE = "token_expiration_date"

    def initialize(session, request)
      @session = session
      @request = request
      @empty_session = @session.nil?
      if not @empty_session and @session.include?(SSO_KEY)
        @token = @session[SSO_KEY][TOKEN_VALUE_KEY]
        @expires_at = @session[SSO_KEY][TOKEN_EXPIRATION_DATE]
      end
    end

    def is_logged_and_valid?
      return false if token_is_empty? 
      user_token_is_correct?
    end

    def user_logged_info
      user_data = decode_user_data
      if user_data 
        return SsoUser.new(user_data['user'])
      end
      return false
    end

    private
    def user_token_is_correct?
      user_data = decode_user_data
      if user_data
        return @token == user_data['token']
      end
      return false
    end

    def decode_user_data
      encripted_user_data = @request.GET['data']
      return false if not encripted_user_data.present?
      user_data = Base64.decode64(encripted_user_data)
      user_data = JSON.load(user_data)
      user_data
    end

    def token_is_empty?
      @token.nil? || @expires_at.nil?
    end

  end
end
