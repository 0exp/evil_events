# frozen_string_literal: true

class EvilEvents::Core::Events::Subscriber
  # @api public
  # @since 0.1.0
  Mixin = EvilEvents::Shared::ClonableModuleBuilder.build do
    # @param event_type [Array<String, Class{EvilEvents::Core::Events::AbstractEvent}, Regexp>]
    # @param delegator [String, Symbol, NilClass]
    # @raise [EvilEvents::ArgumentError]
    #
    # @since 0.2.0
    def subscribe_to(*event_types, delegator: nil)
      raise EvilEvents::ArgumentError unless event_types.all? do |event_type|
        event_type.is_a?(Class) ||
        event_type.is_a?(String) ||
        event_type.is_a?(Regexp) ||
        event_type.is_a?(Proc)
      end

      event_system = EvilEvents::Core::Bootstrap[:event_system]

      event_types.each do |event_type|
        case event_type
        when Class  then event_system.observe(event_type, self, delegator)
        when String then event_system.raw_observe(event_type, self, delegator)
        when Regexp then event_system.observe_list(event_type, self, delegator)
        when Proc   then event_system.conditional_observe(event_type, self, delegator)
        end
      end
    end
  end
end
