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
        unless serialized_event.s_a?(String)
          raise EvilEvents::JSONDeserializationError
        end

        begin
          serialization_state = engine.load(serialized_event)
        rescue EvilEvents::SerializationEngineError
          raise EvilEvents::JSONDeserializationError
        end

        unless serialization_state.valid?
          raise EvilEvents::JSONDeserializationError
        end

        restore_event_instance(serialization_state)
      end
    end
  end
end
