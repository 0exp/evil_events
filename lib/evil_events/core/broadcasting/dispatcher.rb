# frozen_string_literal: true

module EvilEvents::Core::Broadcasting
  # @api private
  # @since 0.1.0
  class Dispatcher # Broadcaster
    class << self
      # @param event [EvilEvents::Core::Events::AbstractEvent]
      # @return void
      #
      # @since 0.1.0
      def dispatch(event) # Broadcast
        EvilEvents::Core::Bootstrap[:event_system].manager_of_event(event).notify(event)
      end
    end
  end
end
