# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.1.0
  module Emitter
    class << self
      # @see EvilEvents::Core::System
      # @api public
      # @since 0.1.0
      def emit(event_type, id: nil, payload: {}, metadata: {}, adapter: nil)
        EvilEvents::Core::Bootstrap[:event_system].raw_emit(
          event_type, id: id, payload: payload, metadata: metadata, adapter: adapter
        )
      end
    end
  end
end
