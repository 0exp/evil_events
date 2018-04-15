# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  module XML
    # @since 0.4.0
    extend Base

    class << self
      # @param event [EvilEvents::Core::Events::AbstractEvent]
      # @raise [EvilEvents::XMLSerializationError]
      # @return [String]
      #
      # @api private
      # @since 0.4.0
      def serialize(event)
        unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
          raise EvilEvents::XMLSerializationError
        end

        Ox.dump(EventSerializationProxy.new(event))
      end

      # @param xml [String]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @api private
      # @since 0.4.0
      def deserialize(xml)
        raise EvilEvents::XMLDeserializationError unless xml.is_a?(String)

        begin
          serialization_proxy = Ox.parse_obj(xml)
        rescue Ox::Error => error
          raise EvilEvents::XMLDeserializationError, error.message
        rescue NoMethodError
          raise EvilEvents::XMLDeserializationError
        end

        restore_event_instance(
          id:       serialization_proxy.id,
          type:     serialization_proxy.type,
          payload:  serialization_proxy.payload,
          metadata: serialization_proxy.metadata
        )
      end
    end
  end

  register(:xml) { XML }
end
