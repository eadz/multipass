require "multipass/engine"
require "multipass/version"
require "multipass/errors"
require 'active_support/message_encryptor'
require 'active_support/message_verifier'
require 'active_support/key_generator'
require 'json'

class MultiPass
  EXPIRY_SECONDS = 30

  def self.encode(site_key, api_key, data, expires = Time.now + EXPIRY_SECONDS)
    Engine.new(site_key, api_key).encode(data, expires)
  end

  def self.decode(site_key, api_key, data)
    Engine.new(site_key, api_key).decode(data)
  end
end
