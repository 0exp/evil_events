# frozen_string_literal: true

module EvilEvents::Core::Broadcasting
  class Dispatcher
    # @api private
    # @since 0.1.0
    Mixin = EvilEvents::Shared::ClonableModuleBuilder.build do
      def dispatch(event)
        Dispatcher.dispatch(event)
      end
    end
  end
end
