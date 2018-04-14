# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  module XML
    extend Base

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [EvilEvents::JSONSerializaionError]
    # @return [String]
    #
    # @api private
    # @since 0.4.0
    def serialize(event)
      unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
        raise EvilEvents::JSONSerializationError
      end


    end

    # @param xml [String]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.4.0
    def deserialize(xml)
    end
  end

  register(:xml) { XML }
end
