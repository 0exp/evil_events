# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  class Serializers
    # @since 0.1.0
    extend EvilEvents::Shared::DependencyContainer::Mixin

    # @since 0.1.0
    SerializersError = Class.new(EvilEvents::Core::Error)
    # @since 0.1.0
    SerializationError = Class.new(SerializersError)
    # @since 0.1.0
    DeserializationError = Class.new(SerializersError)
  end
end
