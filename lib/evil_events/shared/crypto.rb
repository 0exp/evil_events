# frozen_string_literal: true

module EvilEvents::Shared
  # @api public
  # @since 0.1.0
  module Crypto
    module_function

    # @return [String]
    #
    # @api public
    # @since 0.1.0
    def uuid
      ::SecureRandom.uuid
    end
  end
end
