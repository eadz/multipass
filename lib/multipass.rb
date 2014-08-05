require "multipass/version"
require 'active_support/message_encryptor'
require 'active_support/message_verifier'
require 'active_support/key_generator'
require 'json'
require 'base64'

class MultiPass
  class Invalid < StandardError
    class << self
      attr_accessor :message
    end

    self.message = "The MultiPass token is invalid."

    attr_reader :data, :json, :options

    def initialize(data = nil, json = nil, options = nil)
      @data    = data
      @json    = json
      @options = options
    end

    def message
      self.class.message
    end

    alias to_s message
  end

  class ExpiredError < Invalid
    self.message = "The MultiPass token has expired."
  end
  class JSONError < Invalid
    self.message = "The decrypted MultiPass token is not valid JSON."
  end
  class DecryptError < Invalid
    self.message = "The MultiPass token was not able to be decrypted."
  end

  def initialize(site_key, api_key)
    salt = OpenSSL::Digest::SHA256.new(api_key).digest
    password = OpenSSL::Digest::SHA256.new(site_key).digest
    key = ActiveSupport::KeyGenerator.new(password).generate_key(salt)
    @crypt = ActiveSupport::MessageEncryptor.new(key)
  end

  # Encrypts the given hash into a multipass string.
  def encode(data, expires: nil)
    h = {:data => JSON.dump(data)}
    h[:expires] = expires.to_i if expires
    @crypt.encrypt_and_sign(h)
  end

  # Decrypts the given multipass string and parses it as JSON.
  #Then, it checks for a valid expiration date.
  def decode(data)
    hash = @crypt.decrypt_and_verify(data)

    if hash.nil?
      raise MultiPass::DecryptError.new(data)
    end

    if !hash.is_a?(Hash)
      raise MultiPass::JSONError.new
    end

    # Force everything coming out of json into a Time object if it isn't already
    if hash.has_key?(:expires)
      raise MultiPass::ExpiredError.new(data, hash) if Time.now.to_i > hash[:expires].to_i
    end

    JSON.load(hash[:data])
  rescue CipherError
    raise MultiPass::DecryptError.new(data, hash, options)
  end

  CipherError = OpenSSL.const_defined?(:CipherError) ? OpenSSL::CipherError : OpenSSL::Cipher::CipherError

end
