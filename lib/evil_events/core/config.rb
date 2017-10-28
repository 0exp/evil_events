# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  class Config
    class << self
      # @api private
      # @since 0.1.0
      def build_stub
        new
      end
    end

    # @api private
    # @since 0.1.0
    def initialize
      @config = Module.new do
        extend EvilEvents::Shared::Configurable

        setting :adapter, reader: true do
          setting :default, :memory_sync
        end

        setting :subscriber, reader: true do
          setting :default_delegator, :call
        end

        setting :logger, EvilEvents::Shared::Logger.new(STDOUT), reader: true
      end
    end

    private

    # @return [Module{EvilEvents::Shared::Configurable}]
    #
    # @api private
    # @since 0.1.0
    attr_reader :config

    # @api private
    # @since 0.1.0
    def method_missing(method_name, *attributes, &block)
      return super unless config.respond_to?(method_name)
      config.public_send(method_name, *attributes, &block)
    end

    # @api private
    # @since 0.1.0
    def respond_to_missing?(method_name, include_private = false)
      config.respond_to?(method_name, include_private) || super
    end
  end
end
