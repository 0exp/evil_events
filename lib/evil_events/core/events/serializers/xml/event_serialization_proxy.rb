# frozen_string_literal: true

module EvilEvents::Core::Events::Serializers::Xml
  # @api private
  # @since 0.4.0
  class EventSerializationProxy
    # @return [Integer]
    #
    # @since 0.4.0
    attr_reader :id

    # @return [String]
    #
    # @since 0.4.0
    attr_reader :type

    # @return [::Hash]
    #
    # @since 0.4.0
    attr_reader :payload

    # @return [::Hash]
    #
    # @since 0.4.0
    attr_reader :metadata


    # @param event [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.4.0
    def initialize(event)
      @id       = event.id
      @type     = event.type
      @payload  = event.payload
      @metadata = event.metadata
    end
  end
end
