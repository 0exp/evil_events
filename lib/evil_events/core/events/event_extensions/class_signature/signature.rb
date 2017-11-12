# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions::ClassSignature
  # @api private
  # @since 0.2.0
  class Signature
    # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
    attr_reader :event_class

    # @param event_calass [Class{EvilEvents::Core::Events::AbstractEvent}]
    #
    # @since 0.2.0
    def initialize(event_class)
      @event_class = event_class
    end

    # @return [Hash]
    #
    # @since 0.2.0
    def payload_stamp
      event_class::Payload.schema
    end

    # @return [Hash]
    #
    # @since 0.2.0
    def metadata_stamp
      event_class::Metadata.schema
    end

    # @return [String]
    #
    # @since 0.2.0
    def class_stamp
      event_class.name
    end

    # @return [String]
    #
    # @since 0.2.0
    def type_alias_stamp
      event_class.type
    end

    # @return [Symbol,String]
    #
    # @since 0.2.0
    def delegator_stamp
      event_class.default_delegator
    end

    # @return [Hash]
    #
    # @since 0.2.0
    def adapter_stamp
      { event_class.adapter_name => event_class.adapter }
    end

    # @return [Boolean]
    #
    # @since 0.2.0
    def ==(signature)
      Equalizer.new(self, signature).similar_signatures?
    end
    alias_method :eql?, :==
  end
end
