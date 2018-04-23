# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class JSON
    # @api private
    # @since 0.4.0
    class Unpacker < Base::DataTransformer
      # @param serialized_event [String]
      # @raise [EvilEvents::JSONDeserializationError]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @see Base::DataTransformer
      #
      # @api private
      # @since 0.4.0
      def call(serialized_event)
        raise EvilEvents::JSONDeserializationError unless serialized_event.s_a?(String)

        begin
          serialization_state = engine.load(serialized_event)
        rescue EvilEvents::SerializationEngineError
          raise EvilEvents::JSONDeserializationError
        end

        raise EvilEvents::JSONDeserializationError unless serialization_state.valid?

        restore_event_instance(serialization_state)
      end
    end
  end
end
