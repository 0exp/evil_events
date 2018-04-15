# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api public
  # @since 0.1.0
  module Hash
    # @since 0.1.1
    extend Base

    class << self
      # @param event [EvilEvents::Core::Events::AbstractEvent]
      # @raise [EvilEvents::HashSerializationError]
      # @return [::Hash]
      #
      # @since 0.1.0
      def serialize(event)
        unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
          raise EvilEvents::HashSerializationError
        end

        {
          id:       event.id,
          type:     event.type,
          payload:  event.payload,
          metadata: event.metadata
        }
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity

      # @param hash [::Hash]
      # @raise [EvilEvents::HashDeserializationError]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @since 0.1.0
      def deserialize(hash)
        raise EvilEvents::HashDeserializationError unless hash.is_a?(::Hash)

        event_id       = hash[:id]       || hash['id']
        event_type     = hash[:type]     || hash['type']
        event_payload  = hash[:payload]  || hash['payload']
        event_metadata = hash[:metadata] || hash['metadata']

        unless event_type && event_payload && event_metadata
          raise EvilEvents::HashDeserializationError
        end

        raise EvilEvents::HashDeserializationError unless event_payload.is_a?(::Hash)
        raise EvilEvents::HashDeserializationError unless event_metadata.is_a?(::Hash)

        restore_event_instance(
          type:     event_type,
          id:       event_id,
          payload:  symbolized_event_data(event_payload),
          metadata: symbolized_event_data(event_metadata)
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      private

      # @param payload_hash [::Hash]
      # @return [::Hash]
      #
      # @since 0.1.0
      def symbolized_event_data(payload_hash)
        payload_hash.each_pair.each_with_object({}) do |(key, value), result_hash|
          result_hash[key.to_sym] = value
        end
      end
    end
  end

  # @since 0.1.0
  register(:hash) { Hash }
end
