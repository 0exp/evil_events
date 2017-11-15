# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.2.0
  class Plugins
    # @since 0.2.0
    extend Shared::DependencyContainer::Mixin

    # @since 0.2.0
    register(:rails, 'plugins/rails')
    # @since 0.2.0
    register(:elastic_search, 'plugins/elastic_search')

    class << self
      # @return [Array<String>]
      #
      # @since 0.2.0
      def names
        keys
      end

      # @param *plugins [String,Symbol]
      # @return void
      #
      # @api public
      # @since 0.2.0
      def load!(*plugins)
        (plugins.empty? ? names : plugins).each { |plugin| require_relative resolve(plugin) }
      end
    end
  end
end
