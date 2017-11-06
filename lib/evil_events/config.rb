# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.1.0
  module Config
    require_relative 'config/adapters'
    require_relative 'config/types'

    class << self
      # @see EvilEvents::Core::Config
      # @api public
      # @since 0.1.0
      def options
        EvilEvents::Core::Bootstrap[:config]
      end

      # @see EvilEvents::Core::Config
      # @api public
      # @since 0.1.0
      def configure
        options.configure { |conf| yield(conf) if block_given? }
      end

      # @see EvilEvents::Config::TypesSetup
      # @api public
      # @since 0.2.0
      def setup_types
        yield(Config::Types) if block_given?
      end

      # @see EvilEvents::Config::adapters
      # @api public
      # @since 0.2.0
      def setup_adapters
        yield(Config::Adapters) if block_given?
      end
    end
  end
end
