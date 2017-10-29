# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.1.0
  module Config
    class << self
      # @see EvilEvents::Config
      # @api public
      # @since 0.1.0
      def configure
        options.configure { |conf| yield(conf) if block_given? }
      end

      # @see EvilEvents::Config
      # @api public
      # @since 0.1.0
      def options
        EvilEvents::Core::Bootstrap[:config]
      end
    end
  end
end
