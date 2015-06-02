module SsoClient
  class SsoUser
    attr_reader :email, :name, :login, :applications

    def initialize(params)
      @login = params['login']
      @email = params['email']
      @name = params['first_name'] + ' ' + params['last_name']
      @applications = params['applications']
    end

    def to_s
      @email + @name
    end
  end
end
