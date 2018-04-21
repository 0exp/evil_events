# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.1.0
  class JSON < Base
    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [EvilEvents::JSONSerializationError]
    # @return [String]
    #
    # @since 0.1.0
    def serialize(event)
      unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
        raise EvilEvents::JSONSerializationError
      end

      ::JSON.generate(
        id:       event.id,
        type:     event.type,
        payload:  event.payload,
        metadata: event.metadata
      )
    end

    # @param json [String]
    # @raise [EvilEvents::JSONDeserializationError]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.0
    def deserialize(json)
      raise EvilEvents::JSONDeserializationError unless json.is_a?(String)

      begin
        json_hash = ::JSON.parse(json, symbolize_names: true)
      rescue ::JSON::ParserError
        raise EvilEvents::JSONDeserializationError
      end

      event_id       = json_hash[:id]
      event_type     = json_hash[:type]
      event_payload  = json_hash[:payload]
      event_metadata = json_hash[:metadata]

      unless event_type && event_payload && event_metadata
        raise EvilEvents::JSONDeserializationError
      end

      raise EvilEvents::JSONDeserializationError unless event_payload.is_a?(::Hash)
      raise EvilEvents::JSONDeserializationError unless event_metadata.is_a?(::Hash)

      restore_event_instance(
        type:     event_type,
        id:       event_id,
        payload:  event_payload,
        metadata: event_metadata
      )
    end
  end

  # @since 0.1.0
  register(:json) { JSON.new }
end
