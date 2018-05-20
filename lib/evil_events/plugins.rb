# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.2.0
  class Plugins
    require_relative 'plugins/oj_engine'
    require_relative 'plugins/ox_engine'
    require_relative 'plugins/mpacker_engine'

    # @since 0.3.0
    extend Shared::ExtensionsMixin

    # @since 0.5.0
    register_extension(:oj_engine) { OjEngine.load! }
    # @since 0.5.0
    register_extension(:ox_engine) { OxEngine.load! }
    # @since 0.5.0
    register_extension(:mpacker_engine) { MpackerEngine.load! }

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
