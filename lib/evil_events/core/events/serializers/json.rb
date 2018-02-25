# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api public
  # @since 0.1.0
  module JSON
    # @since 0.1.1
    extend Base

    class << self
      # @param event [EvilEvents::Core::Events::AbstractEvent]
      # @raise [EvilEvents::SerializationError]
      # @return [::Hash]
      #
      # @since 0.1.0
      def serialize(event)
        unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
          raise EvilEvents::SerializationError
        end

        ::JSON.generate(
          id:       event.id,
          type:     event.type,
          payload:  event.payload,
          metadata: event.metadata
        )
      end

      # @param json [String]
      # @raise [EvilEvents::DeserializationError]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @since 0.1.0
      def deserialize(json)
        raise EvilEvents::DeserializationError unless json.is_a?(String)

        begin
          json_hash      = ::JSON.parse(json, symbolize_names: true)
          event_id       = json_hash[:id]
          event_type     = json_hash[:type]
          event_payload  = json_hash[:payload]
          event_metadata = json_hash[:metadata]

          unless event_type && event_payload && event_metadata
            raise EvilEvents::DeserializationError
          end
        rescue ::JSON::ParserError
          raise EvilEvents::DeserializationError
        end

        restore_event_instance(
          type:     event_type,
          id:       event_id,
          payload:  event_payload,
          metadata: event_metadata
        )
      end
    end
  end

  # @since 0.1.0
  register(:json) { JSON }
end
