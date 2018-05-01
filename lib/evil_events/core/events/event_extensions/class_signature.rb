# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.2.0
  module ClassSignature
    class << self
      # @param base_calss [Class{AbstractEvent}]
      #
      # @since 0.2.0
      def included(base_class)
        base_class.extend(ClassMethods)

        base_class.singleton_class.class_eval do
          attr_accessor :__creation_strategy__
        end
      end
    end

    # @param another_event [Object]
    # @return [Boolean]
    #
    # @since 0.4.0
    def similar_to?(another_event)
      id       == another_event.id &&
      type     == another_event.type &&
      payload  == another_event.payload &&
      metadata == another_event.metadata
    rescue NoMethodError
      false
    end

    # @since 0.2.0
    module ClassMethods
      # @return [Signature]
      #
      # @since 0.2.0
      def signature
        Signature.new(self)
      end
    end
  end
end
