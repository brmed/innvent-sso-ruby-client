require 'openssl'
module SsoClient
  class CryptoAdapter
    def initialize
      @encryptor = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/server_key.pub")))
    end

    def decrypt(data)
      @encryptor.public_decrypt(Base64.decode64(data))
    end
  end
end