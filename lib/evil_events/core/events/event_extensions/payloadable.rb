# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module Payloadable
    class << self
      # @param base_class [Class]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    private

    # @return [Class{AbstractPayload}]
    #
    # @since 0.1.0
    def build_payload(**payload_attributes)
      self.class.const_get(:Payload).new(**payload_attributes)
    end

    # @since 0.1.0
    module ClassMethods
      # @param child_class [Class]
      #
      # @since 0.1.0
      def inherited(child_class)
        child_class.const_set(:Payload, Class.new(AbstractPayload))
        super
      end

      # @param key [Symbol]
      # @param type [EvilEvents::Shared::Types::Any]
      # @return void
      #
      # @since 0.1.0
      def payload(key, type = EvilEvents::Types::Any)
        const_get(:Payload).attribute(key, type)
      end

      # @return [Array<Symbol>]
      #
      # @since 0.1.0
      def payload_fields
        const_get(:Payload).attribute_names
      end
    end
  end
end
