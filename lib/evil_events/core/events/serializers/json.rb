# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api public
  # @since 0.1.0
  module JSON
    module_function

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [SerializationError]
    # @return [::Hash]
    #
    # @since 0.1.0
    def serialize(event)
      raise SerializationError unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)

      ::JSON.generate(type: event.type, payload: event.payload, metadata: event.metadata)
    end

    # @param json [String]
    # @raise [DeserializationError]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.0
    def deserialize(json)
      raise DeserializationError unless json.is_a?(String)

      begin
        json_hash      = ::JSON.parse(json, symbolize_names: true)
        event_type     = json_hash[:type]
        event_payload  = json_hash[:payload]
        event_metadata = json_hash[:metadata]
        raise DeserializationError unless event_type && event_payload && event_metadata
      rescue ::JSON::ParserError
        raise DeserializationError
      end

      EvilEvents::Core::Bootstrap[:event_system].resolve_event_object(
        event_type, payload: event_payload, metadata: event_metadata
      )
    end
  end

  # @since 0.1.0
  register(:json) { JSON }
end
