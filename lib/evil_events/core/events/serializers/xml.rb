# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  class XML < Base
    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [EvilEvents::XMLSerializationError]
    # @return [String]
    #
    # @api private
    # @since 0.4.0
    def serialize(event)
      unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
        raise EvilEvents::XMLSerializationError
      end

      ::Ox.dump(EventSerializationState.new(event))
    end

    # @param xml [String]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.4.0
    def deserialize(xml)
      raise EvilEvents::XMLDeserializationError unless xml.is_a?(String)

      begin
        event_serialization_state = Ox.parse_obj(xml)
      rescue ::Ox::Error, NoMethodError, ArgumentError
        raise EvilEvents::XMLDeserializationError
      end

      restore_event_instance(
        id:       event_serialization_state.id,
        type:     event_serialization_state.type,
        payload:  event_serialization_state.payload,
        metadata: event_serialization_state.metadata
      )
    end
  end

  register(:xml) { XML.new }
end
