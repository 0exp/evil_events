# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::JSON::Engines
  # @api private
  # @since 0.5.0
  class Oj < EvilEvents::Core::Events::Serializers::Base::AbstractEngine
    # @param serialization_state [Base::EventSerializationState]
    # @return [String]
    #
    # @since 0.5.0
    # @api private
    def dump(serialization_state)
      ::Oj.dump(
        id:       serialization_state.id,
        type:     serialization_state.type,
        payload:  serialization_state.payload,
        metadata: serialization_state.metadata
      )
    end

    # @param json_string [String]
    # @raise [EvilEvents::SerializationEngineError]
    # @return [EventSerializationState]
    #
    # @since 0.5.0
    # @api private
    def load(json_string)
      json = ::Oj.load(json_string, symbol_keys: true)

      restore_serialization_state(
        id:       json[:id],
        type:     json[:type],
        payload:  json[:payload],
        metadata: json[:metadata]
      )
    rescue ::Oj::Error, NoMethodError, TypeError
      raise EvilEvents::SerializationEngineError
    end
  end

  # @since 0.5.0
  register(:oj, Oj)
end
