module Sso
  class LoginsController < ApplicationController
    skip_filter :authenticate_user!, only: [:create]

    rescue_from SsoClient::SsoServerNotReachableError do |exception|
      render :text => "SSO server is not running or is not accessible!!", status: 500
    end

    def create
      begin
        session_handler = SsoClient::SessionHandler.new(session)
        session_handler.validate_is_authorized_to_callback!(params['data'])
        user = session_handler.store_user_on_session(params)
        after_logged_in(user)
      rescue SsoClient::InvalidTokenError => e
        render text: e.message
      end
    end

    def destroy
      sso_logout
    end
  end
end