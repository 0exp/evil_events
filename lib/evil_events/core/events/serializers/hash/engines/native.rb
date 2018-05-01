# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Hash::Engines
  # @api private
  # @since 0.4.0
  class Native < EvilEvents::Core::Events::Serializers::Base::AbstractEngine
    # @param serialization_state [Base::EventSerializationState]
    # @return [::Hash]
    #
    # @since 0.4.0
    # @api private
    def dump(serialization_state)
      {
        id:       serialization_state.id,
        type:     serialization_state.type,
        payload:  serialization_state.payload,
        metadata: serialization_state.metadata
      }
    end

    # @param hash [::Hash]
    # @raise [EvilEvents::SerializationEngineError]
    # @return [EventSerializationState]
    #
    # @since 0.4.0
    # @api private
    def load(hash)
      begin
        event_id       = hash[:id]       || hash['id']
        event_type     = hash[:type]     || hash['type']
        event_payload  = hash[:payload]  || hash['payload']
        event_metadata = hash[:metadata] || hash['metadata']
      rescue NoMethodError, TypeError, ArgumentError
        raise EvilEvents::SerializationEngineError
      end

      restore_serialization_state(
        id:       event_id,
        type:     event_type,
        payload:  (symbolized_hash(event_payload)  if event_payload),
        metadata: (symbolized_hash(event_metadata) if event_metadata)
      )
    end

    private

    # @param hash [::Hash]
    # @return [::Hash]
    #
    # @since 0.1.0
    def symbolized_hash(hash)
      hash.each_pair.each_with_object({}) do |(key, value), result_hash|
        result_hash[key.to_sym] = value
      end
    end
  end

  # @since 0.4.0
  register(:native, Native)
end
