# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.2.0
  module Application
    class << self
      # @see EvilEvents::Core::System
      # @api public
      # @since 0.2.0
      def registered_events
        EvilEvents::Core::Bootstrap[:event_system].registered_events
      end

      # @see EvilEvents::Core::System
      # @api public
      # @since 0.3.0
      def restart_event_notifier
        EvilEvents::Core::Bootstrap[:event_system].restart_event_notifier
      end
    end
  end
end
