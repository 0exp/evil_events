# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api public
  # @since 0.1.0
  module Hash
    module_function

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [SerializationError]
    # @return [::Hash]
    #
    # @since 0.1.0
    def serialize(event)
      raise SerializationError unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)

      { type: event.type, payload: event.payload, metadata: event.metadata }
    end

    # @param hash [::Hash]
    # @raise [DeserializationError]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.0
    def deserialize(hash) # rubocop:disable Metrics/AbcSize
      raise DeserializationError unless hash.is_a?(::Hash)
      event_type     = hash[:type]     || hash['type']
      event_payload  = hash[:payload]  || hash['payload']
      event_metadata = hash[:metadata] || hash['metadata']
      raise DeserializationError unless event_type && event_payload && event_metadata
      raise DeserializationError unless event_payload.is_a?(::Hash) && event_metadata.is_a?(::Hash)

      EvilEvents::Core::Bootstrap[:event_system].resolve_event_object(
        event_type,
        payload:  symbolized_event_data(event_payload),
        metadata: symbolized_event_data(event_metadata)
      )
    end

    # @param payload_hash [::Hash]
    # @return [::Hash]
    #
    # @since 0.1.0
    def symbolized_event_data(payload_hash)
      payload_hash.each_pair.each_with_object({}) do |(key, value), result_hash|
        result_hash[key.to_sym] = value
      end
    end
    private_class_method :symbolized_event_data
  end

  # @since 0.1.0
  register(:hash) { Hash }
end
