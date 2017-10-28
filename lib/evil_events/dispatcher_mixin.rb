# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.1.0
  DispatcherMixin = EvilEvents::Core::Broadcasting::Dispatcher::Mixin.module_clone
end
