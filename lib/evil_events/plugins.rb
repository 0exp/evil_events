# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.2.0
  class Plugins
    # @since 0.3.0
    extend Shared::ExtensionsMixin

    # @since 0.3.0
    register_extension(:redis_adapter) { require_relative 'plugins/redis_adapter' }
    # @since 0.3.0
    register_extension(:sidekiq_adapter) { require_relative 'plugins/sidekiq_adapter' }

    class << self
      # @param plugins [Symbol,Symbol,Symbol,...]
      # @raise [ArgumentError] When required plugin is not registered
      # @return void
      #
      # @api public
      # @since 0.2.0
      def load!(*plugins)
        load_extensions(*(plugins.empty? ? names : plugins))
      end

      # @return [Array<Symbol>]
      #
      # @api public
      # @since 0.2.0
      def names
        @__available_extensions__.keys
      end
    end
  end
end
