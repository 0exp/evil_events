# frozen_string_literal: true

module EvilEvents::Config
  # @api public
  # @since 0.2.0
  module TypesSetup
    class << self

      # @see EvilEvents::Core::System
      # @since 0.2.0
      def define_converter(type, &block)
        EvilEvents::Core::Bootstrap[:event_system].register_converter(type, &block)
      end

      # @see EvilEvents::Core::System
      # @since 0.2.0
      def resolve_type(type)
        EvilEvents::Core::Bootstrap[:event_system].resolve_type(type)
      end
    end
  end
end
