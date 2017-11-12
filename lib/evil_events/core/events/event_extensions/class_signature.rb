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
      end
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
