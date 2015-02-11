module SsoClient
  class SessionHandler
    SSO_KEY = :sso_token
    SSO_USER_KEY = :sso_user
    TOKEN_VALUE_KEY = "token_secret"
    TOKEN_EXPIRATION_DATE = "token_expiration_date"

    def initialize(session)
      @session = session
    end

    def sessions_are_valid?
      if @session[SSO_KEY].nil? or @session[SSO_USER_KEY].nil? or @session[SSO_KEY].empty?
        return false
      else
        token = @session[SSO_KEY][TOKEN_VALUE_KEY]
        expires_at = @session[SSO_KEY][TOKEN_EXPIRATION_DATE]
        return false if expires_at.nil? or Time.parse(expires_at) <= Time.now
      end
      true
    end

    def store_sso_data(token, expires_at)
      @session[SSO_KEY] ||= {}
      @session[SSO_KEY][TOKEN_VALUE_KEY] = token
      @session[SSO_KEY][TOKEN_EXPIRATION_DATE] = expires_at
    end

    def stored_token
      @session[SSO_KEY][TOKEN_VALUE_KEY]
    end

    def stored_user
      SsoUser.new(@session[SSO_USER_KEY]) unless @session[SSO_USER_KEY].nil?
    end

    def delete_sso_sessions!
      @session.delete(SSO_KEY)
      @session.delete(SSO_USER_KEY)
    end

    def store_user_on_session(params)
      data = Base64.decode64(params['data'])
      params = JSON.parse(data)['user']
      user = SsoClient::SsoUser.new(params)
      @session[SSO_USER_KEY] = params
      user
    end

    def validate_is_authorized_to_callback!(data)
      token_is_valid = true
      begin
        data = Base64.decode64(data)
        params_json = JSON.parse(data)
        token = params_json['token']
        user = SsoUser.new(params_json['user'])
        token_is_valid = (@session[SSO_KEY][TOKEN_VALUE_KEY] + user.to_s) == CryptoAdapter.new.decrypt(token)
      rescue => e
        raise InvalidTokenError, "The supplied token is not valid! (#{e.message})" if !token_is_valid
      end

    end
  end
end
