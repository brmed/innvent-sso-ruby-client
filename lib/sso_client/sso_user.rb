module SsoClient
  class SsoUser
    attr_reader :email, :name, :login

    def initialize(params)
      @login = params['login']
      @email = params['email']
      @name = params['first_name'] + ' ' + params['last_name']
    end

    def to_s
      @email + @name
    end
  end
end
