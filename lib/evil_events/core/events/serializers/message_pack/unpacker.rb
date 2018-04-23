# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class MessagePack
    # @api private
    # @since 0.4.0
    class Unpacker < Base::DataTransformer
      # @param serialized_event [String]
      # @raise [EvilEvents::MessagePackDeserializationErro]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @see Base::DataTransformer
      #
      # @api private
      # @since 0.4.0
      def call(serialized_event)
        unless serialized_event.is_a?(String)
          raise EvilEvents::MessagePackDeserializationErro
        end

        serialization_state = engine.load(serialized_event)

        unless serialization_state.valid?
          raise EvilEvents::MessagePackDeserializationErro
        end

        restore_event_instance(serialization_state)
      end
    end
  end
end
