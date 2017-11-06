# frozen_string_literal: true

module EvilEvents::Config
  # @api public
  # @since 0.2.0
  module Types
    class << self
      # @see EvilEvents::Core::System
      # @api public
      # @since 0.2.0
      def define_converter(type, &coercer)
        EvilEvents::Core::Bootstrap[:event_system].register_converter(type, coercer)
      end

      # @see EvilEvents::Core::System
      # @api public
      # @since 0.2.0
      def resolve_type(type, **options)
        EvilEvents::Core::Bootstrap[:event_system].resolve_type(type, **options)
      end
      alias_method :[], :resolve_type
    end
  end
end
