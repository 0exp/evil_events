# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  class Bootstrap
    # @since 0.1.0
    extend EvilEvents::Shared::DependencyContainer::Mixin

    register(:event_system, memoize: true) { EvilEvents::Core::System.new }
    register(:config, memoize: true) { EvilEvents::Core::Config.new }
  end
end
