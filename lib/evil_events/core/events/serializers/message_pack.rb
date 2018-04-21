# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  class MessagePack < Base
    def factory
      @factory ||= ::MessagePack::Factory.new
    end

    def packer
      factory.packer
    end

    def unpacker
      factory.unpacker
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [EvilEvents::MessagePackSerializationError]
    # @return [String]
    #
    # @api private
    # @since 0.4.0
    def serialize(event)
      unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
        raise EvilEvents::MessagePackSerializationError
      end

      packer.pack(
        id:       event.id,
        type:     event.type,
        payload:  event.payload,
        metadata: event.metadata
      ).to_str
    end

    # @param message [String]
    # @raise [EvilEvents::MessagePackDeserializationError]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.4.0
    def deserialize(message)
      raise EvilEvents::MessagePackDeserializationError unless message.is_a?(String)

      begin
        event_state = unpacker.feed(message).unpack
      rescue ::MessagePack::UnpackError
        raise EvilEvents::MessagePackDeserializationError
      end

      begin
        event_id       = event_state["id"]
        event_type     = event_state["type"]
        event_payload  = event_state["payload"]
        event_metadata = event_state["metadata"]
      rescue NoMethodError
        raise EvilEvents::MessagePackDeserializationError
      end

      unless event_type && event_payload && event_metadata
        raise EvilEvents::MessagePackDeserializationError
      end

      raise EvilEvents::MessagePackDeserializationError unless event_payload.is_a?(::Hash)
      raise EvilEvents::MessagePackDeserializationError unless event_metadata.is_a?(::Hash)

      restore_event_instance(
        id:       event_id,
        type:     event_type,
        payload:  symbolized_event_data(event_payload),
        metadata: symbolized_event_data(event_metadata),
      )
    end

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

  # @since 0.4.0
  register(:msgpack) { MessagePack.new }
end
