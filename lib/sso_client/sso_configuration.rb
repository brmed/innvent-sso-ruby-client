require 'singleton'
module SsoClient
  class SsoConfiguration
    include Singleton
    def initialize
      @config_file = YAML.load_file("#{Rails.root.join("config")}/sso_client.yml")
    end

    def sso_server_address
      @config_file["server_address"]     
    end

    def api_username
      @config_file["api_username"]
    end

    def api_password
      @config_file["api_password"]
    end

    def allowed_application
      @config_file["allowed_application"] || "default"
    end
  end
end
