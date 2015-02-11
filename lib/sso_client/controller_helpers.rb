require 'httparty'
module SsoClient
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      helper_method :logged_user
      helper_method :sso_logout
    end

    def authenticate_user!
      begin
        if !SessionHandler.new(session).sessions_are_valid? || !sso_authentication_still_valid?
          generate_token
          redirect_to sso_authorize_path
        end
      rescue Errno::ECONNREFUSED => e
        render :text => "SSO server is not running or is not accessible!!"
      end
    end

    def sso_logout
      redirect_to sso_logout_path
    end

    def sso_login_url
      login_path(only_path: false)
    end

    def sso_token_path
      "#{sso_configuration.sso_server_address}/access_token?callback_url=#{sso_login_url}"
    end

    def sso_authorized_path
      "#{sso_configuration.sso_server_address}/authorized#{build_request_params_string}"
    end

    def sso_authorize_path
      "#{sso_configuration.sso_server_address}/authorize#{build_request_params_string}"
    end

    def sso_validate_token_path
      "#{sso_configuration.sso_server_address}/validate_token#{build_request_params_string}"
    end

    def sso_logout_path
      path = "#{sso_configuration.sso_server_address}/logout#{build_request_params_string(on_logged_out_path)}"
      SessionHandler.new(session).delete_sso_sessions!
      path
    end

    def redirect_logged
      redirect_to session.delete(:redirect_url) unless session[:redirect_url].nil?
    end

    def logged_user
      SessionHandler.new(session).stored_user
    end

    private
    def sso_authentication_still_valid?
      token_is_valid?
    end

    def build_request_params_string(url=sso_login_url)
      "?token=#{stored_token_value}&callback_url=#{url}"
    end

    def generate_token
      #FIXME session is hardcoded 1234 to ensure that all services uses the same session id
      response = HTTParty.get(sso_token_path,
                              basic_auth: service_auth_hash,
                              cookies: {session_id: "1234"})
      token = JSON.parse(response.body)['token']
      expires_at = JSON.parse(response.body)['expires_at']
      SessionHandler.new(session).store_sso_data(token, expires_at)
      token
    end

    def stored_token_value
      SessionHandler.new(session).stored_token
    end

    def sso_configuration
      SsoClient::SsoConfiguration.instance
    end

    def token_is_valid?
      response = HTTParty.get(sso_validate_token_path)
      return JSON.parse(response.body)['valid']
    end

    def service_auth_hash
      {
        username: sso_configuration.api_username,
        password: sso_configuration.api_password,
      }
    end
  end
end

