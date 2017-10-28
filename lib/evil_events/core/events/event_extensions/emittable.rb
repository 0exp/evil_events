# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module Emittable
    # @since 0.1.0
    def emit!
      EvilEvents::Core::Bootstrap[:event_system].emit(self)
    end
  end
end
