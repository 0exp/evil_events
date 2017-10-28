# frozen_string_literal: true

class EvilEvents::Core::Events::Manager
  # @api private
  # @since 0.1.0
  class SubscriberList < Concurrent::Array
    # @param source_subscriber [Object]
    # @return [Boolean]
    #
    # @since 0.1.0
    def registered?(source_subscriber)
      any? { |subscriber| subscriber.source_object == source_subscriber }
    end

    # @param source_subscriber [Object]
    # @return [EvilEvents::Core::Events::Subscriber]
    #
    # @since 0.1.0
    def wrapper_of(source_subscriber)
      find { |subscriber| subscriber.source_object == source_subscriber }
    end

    # @return [Array<Object>]
    #
    # @since 0.1.0
    def sources
      map(&:source_object)
    end
  end
end
