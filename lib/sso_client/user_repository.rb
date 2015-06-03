require 'uri'

module SsoClient
  class UserRepository
    def initialize
      @sso_configuration = SsoClient::SsoConfiguration.instance
      @user_by_login_url = @sso_configuration.sso_server_address + "/user_by_login?login="
      @create_user_url = @sso_configuration.sso_server_address + "/users"
      @all_users_url = @sso_configuration.sso_server_address + "/users"
      @update_user_url = @sso_configuration.sso_server_address + "/users/:user_id"
    end

    def create_or_update_user(firstname, lastname, username, email, password)
      user_by_email_url = @user_by_login_url + URI.escape(username)
      response = HTTParty.get(user_by_email_url, basic_auth: build_auth_hash)
      body = build_user_hash(firstname, lastname, username, email, password)
      if response.code == 200
        user_id = JSON.parse(response.body)['id']
        response = HTTParty.post(update_url_for(user_id), body: body, basic_auth: build_auth_hash)
      elsif response.code == 404
        response = HTTParty.post(@create_user_url, body: body, basic_auth: build_auth_hash)
      end
    end

    def find_by_login(login)
      find_by_login_url = @sso_configuration.sso_server_address + "/user_by_login?login=" + login
      response = HTTParty.get(find_by_login_url, basic_auth: build_auth_hash)
      if response.code == 200
        return SsoUser.new(JSON.parse(response.body))
      else
        return nil
      end
    end

    def all_users
      response = HTTParty.get(@all_users_url, basic_auth: build_auth_hash)
      users = JSON.parse(response.body)
      users.map { |u| SsoUser.new(u) }      
    end

    def users_by_application(application)
      response = HTTParty.get(@all_users_url, basic_auth: build_auth_hash)
      users = JSON.parse(response.body)
      by_app = users.select { |u| (u["applications"].include? application.to_s) }
      by_app.map { |u| SsoClient::SsoUser.new(u) }
    end

    private
    def build_auth_hash
      {
        username: @sso_configuration.api_username,
        password: @sso_configuration.api_password,
      }
    end

    def build_user_hash(firstname, lastname, username, email, password)
      {
        :firstname => firstname,
        :lastname => lastname,
        :login => username,
        :email => email,
        :password => password
      }
    end

    def update_url_for(id)
      @update_user_url.gsub(/:user_id/, id.to_s)
    end
  end
end
