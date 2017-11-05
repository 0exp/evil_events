# frozen_string_literal: true

module EvilEvents::Config
  # @api public
  # @since 0.1.0
  module Adapters
    class << self
      # @see EvilEvents::Core::System
      # @api public
      # @since 0.1.0
      def register(adapter_name, adapter_object)
        EvilEvents::Core::Bootstrap[:event_system].register_adapter(adapter_name, adapter_object)
      end

      # @see EvilEvents::Core::System
      # @api public
      # @since 0.1.0
      def resolve(adapter_name)
        EvilEvents::Core::Bootstrap[:event_system].resolve_adapter(adapter_name)
      end
      alias_method :[], :resolve
    end
  end
end
