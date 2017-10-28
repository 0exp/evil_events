# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.1.0
  module Event
    class << self
      # @see EvilEvents::Core::System
      # @api public
      # @since 0.1.0
      def [](event_type)
        EvilEvents::Core::Bootstrap[:event_system].define_abstract_event_class(event_type)
      end

      # @see EvilEvents::Core::System
      # @api public
      # @since 0.1.0
      def define(event_type, &event_class_definitions)
        EvilEvents::Core::Bootstrap[:event_system].define_event_class(
          event_type, &event_class_definitions
        )
      end
    end
  end
end
