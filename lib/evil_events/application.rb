# frozen_string_literal: true

module EvilEvents
  module Application
    class << self
      def registered_events
        EvilEvents::Core::Bootstrap[:event_system].registered_events
      end
    end
  end
end
