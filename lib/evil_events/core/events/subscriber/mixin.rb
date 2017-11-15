# frozen_string_literal: true

class EvilEvents::Core::Events::Subscriber
  # @api public
  # @since 0.1.0
  Mixin = EvilEvents::Shared::ClonableModuleBuilder.build do
    # @param event_type [String, Class{EvilEvents::Core::Events::AbstractEvent}]
    # @param delegator [String, Symbol, NilClass]
    # @raise [IncompatibleEventAttrTypeError]
    #
    # @since 0.1.0
    def subscribe_to(event_type, delegator: nil)
      case event_type
      when Class
        EvilEvents::Core::Bootstrap[:event_system].observe(event_type, self, delegator)
      when String
        EvilEvents::Core::Bootstrap[:event_system].raw_observe(event_type, self, delegator)
      when Regexp
        EvilEvents::Core::Bootstrap[:event_system].observe_list(event_type, self, delegator)
      else
        raise ArgumentError
      end
    end
  end
end
