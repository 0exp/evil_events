# frozen_string_literal: true

module EvilEvents
  # @api public
  # @since 0.1.0
  module Serializer
    class << self
      # @see EvilEvents::Core::System
      # @api public
      # @since 0.1.0
      def load_from_json(serialized_event)
        EvilEvents::Core::Bootstrap[:event_system].deserialize_from_json(serialized_event)
      end

      # @see EvilEvents::Core::System
      # @api public
      # @since 0.1.0
      def load_from_hash(serialized_event)
        EvilEvents::Core::Bootstrap[:event_system].deserialize_from_hash(serialized_event)
      end
    end
  end
end
