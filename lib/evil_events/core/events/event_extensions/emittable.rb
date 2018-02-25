# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module Emittable
    class << self
      # @param base_class [Class{AbstractEvent}]
      #
      # @api private
      # @since 0.3.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @return void
    #
    # @api public
    # @since 0.1.0
    def emit!
      EvilEvents::Core::Bootstrap[:event_system].emit(self)
    end

    module ClassMethods
      # @option id [NilClass, Object]
      # @option payload [Hash]
      # @option metadata [Hash]
      # @return void
      #
      # @see EvilEvents::Core::Events::AbstractEvent#initialize
      # @see EvilEvents::Core::Events::EventExtensions::Emittable#emit!
      #
      # @api public
      # @since 0.3.0
      def emit!(**event_attributes)
        new(**event_attributes).emit!
      end
    end
  end
end
