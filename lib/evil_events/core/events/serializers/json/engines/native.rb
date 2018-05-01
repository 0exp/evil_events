# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::JSON::Engines
  # @api private
  # @since 0.4.0
  class Native < EvilEvents::Core::Events::Serializers::Base::AbstractEngine
    # @param serialization_state [Base::EventSerializationState]
    # @return [String]
    #
    # @since 0.4.0
    # @api private
    def dump(serialization_state)
      ::JSON.generate(
        id:       serialization_state.id,
        type:     serialization_state.type,
        payload:  serialization_state.payload,
        metadata: serialization_state.metadata
      )
    end

    # @param json_string [String]
    # @raise [EvilEvents::JSONDeserializationError]
    # @return [EventSerializationState]
    #
    # @since 0.4.0
    # @api private
    def load(json_string)
      json = ::JSON.parse(json_string, symbolize_names: true)

      restore_serialization_state(
        id:       json[:id],
        type:     json[:type],
        payload:  json[:payload],
        metadata: json[:metadata]
      )
    rescue ::JSON::ParserError, TypeError
      raise EvilEvents::SerializationEngineError
    end
  end

  # @since 0.4.0
  register(:native) { Native }
end
