# frozen_string_literal: true

class EvilEvents::Core::Events::Manager
  # @api private
  # @since 0.1.0
  module Notifier
    # @since 0.1.0
    NotifierError = Class.new(StandardError)
    # @since 0.1.0
    InconsistentEventClassError = Class.new(NotifierError)

    # @since 0.1.0
    class FailedSubscribersError < NotifierError
      # @since 0.1.0
      extend Forwardable

      def_delegators :errors_stack, :<<, :empty?

      # @return [Concurrent::Array]
      #
      # @api public
      # @since 0.1.0
      attr_reader :errors_stack

      # @param message [NilClass, String]
      #
      # @since 0.1.0
      def initialize(message = nil)
        @errors_stack = Concurrent::Array.new
        super
      end
    end

    class << self
      # @param manager [EvilEvents::Core::Events::Manager]
      # @param event [EvilEvents::Core::Events::AbstractEvent]
      # @raise [InconsistentEventClassError]
      # @raise [FailedSubscribersError]
      # @return void
      #
      # @since 0.1.0
      def run(manager, event)
        raise InconsistentEventClassError unless event.is_a?(manager.event_class)

        errors_stack = FailedSubscribersError.new

        manager.subscribers.each do |subscriber|
          begin
            subscriber.notify(event)
          rescue StandardError => error
            errors_stack << error
          end
        end

        raise errors_stack unless errors_stack.empty?
      end
    end
  end
end
