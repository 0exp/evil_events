# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.1.1
  module Base
    # @option type [String]
    # @option id [String, Object]
    # @option payload [Hash]
    # @option metadata [Hash]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.1
    def restore_event_instance(type:, id:, payload:, metadata:)
      event_class = EvilEvents::Core::Bootstrap[:event_system].resolve_event_class(type)

      EvilEvents::Core::Events::EventFactory.restore_instance(
        event_class, id: id, payload: payload, metadata: metadata
      )
    end
  end
end
