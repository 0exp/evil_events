# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class JSON
    # @api private
    # @since 0.4.0
    class Unpacker < Base::DataTransformer
      # @param serializerd_event [String]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @see Base::DataTransformer
      #
      # @api private
      # @since 0.4.0
      def call(serializerd_event)
        begin
          serialization_state = engine.load(serialized_event)
        rescue EvilEvents::SerializationEngineError
          raise EvilEvents::JSONDeserializationError
        end

        raise EvilEvents::JSONDeserializationError unless serialization_state.valid?

        restore_event_instance(state)
      end
    end
  end
end
