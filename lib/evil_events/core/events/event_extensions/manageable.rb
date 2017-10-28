# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module Manageable
    class << self
      # @param base_class [Class]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @since 0.1.0
    module ClassMethods
      # @return void
      #
      # @since 0.1.0
      def manage!
        EvilEvents::Core::Bootstrap[:event_system].register_event_class(self)
      end
    end
  end
end
