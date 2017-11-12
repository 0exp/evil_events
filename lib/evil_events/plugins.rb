# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.2.0
  class Plugins
    # @since 0.2.0
    extend Shared::DependencyContainer::Mixin

    # @since 0.2.0
    register(:rails, 'plugins/rails')

    class << self
      # @param *plugins [Symbol]
      # @return void
      #
      # @api public
      # @since 0.2.0
      def load!(*plugins)
        plugins.each { |plugin| require_relative resolve(plugin) }
      end
    end
  end
end
