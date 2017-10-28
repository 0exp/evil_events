# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  class Serializers
    extend EvilEvents::Shared::DependencyContainer::Mixin

    # @since 0.1.0
    SerializersError = Class.new(StandardError)
    # @since 0.1.0
    SerializationError = Class.new(SerializersError)
    # @since 0.1.0
    DeserializationError = Class.new(SerializersError)
  end
end
