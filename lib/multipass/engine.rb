class MultiPass
  class Engine
    def initialize(site_key, api_key)
      raise MultiPass::MissingKeyError.new unless site_key && api_key && site_key != '' && api_key != ''

      salt = OpenSSL::Digest::SHA256.new(api_key).digest
      password = OpenSSL::Digest::SHA256.new(site_key).digest
      key = ActiveSupport::KeyGenerator.new(password).generate_key(salt)
      @crypt = ActiveSupport::MessageEncryptor.new(key)
    end

    def encode(data, expires)
      h = {:data => JSON.dump(data)}
      h[:expires] = expires.to_i if expires
      @crypt.encrypt_and_sign(h)
    end

    def decode(data)
      hash = @crypt.decrypt_and_verify(data)

      if hash.nil?
        raise MultiPass::DecryptError.new
      end

      if !hash.is_a?(Hash)
        raise MultiPass::DecryptError.new
      end

      if hash.has_key?(:expires)
        raise MultiPass::ExpiredError.new if Time.now.to_i > hash[:expires].to_i
      end

      JSON.load(hash[:data])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      raise MultiPass::DecryptError.new
    end
  end
end
