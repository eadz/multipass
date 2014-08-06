class MultiPass
  class Invalid < StandardError
    class << self
      attr_accessor :message
    end

    self.message = "The MultiPass token is invalid."

    def to_s
      self.class.message
    end
  end

  class ExpiredError < Invalid
    self.message = "The MultiPass token has expired."
  end
  class DecryptError < Invalid
    self.message = "The MultiPass token was not able to be decrypted."
  end
  class MissingKeyError < Invalid
    self.message = "Missing site key or api key"
  end
end
