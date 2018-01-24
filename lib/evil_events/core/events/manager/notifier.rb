# frozen_string_literal: true

class EvilEvents::Core::Events::Manager
  # @api private
  # @since 0.1.0
  module Notifier
    # @since 0.1.0
    NotifierError = Class.new(EvilEvents::Core::Error)
    # @since 0.1.0
    InconsistentEventClassError = Class.new(NotifierError)

    # @since 0.1.0
    class FailedSubscribersError < NotifierError
      # @since 0.1.0
      extend Forwardable

      # @since 0.1.0
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
        event.__call_before_hooks__
        manager.subscribers.each do |subscriber|
          begin
            subscriber.notify(event)
            log_activity(event, subscriber, :successful)
          rescue StandardError => error
            event.__call_on_error_hooks__(error)
            errors_stack << error
            log_activity(event, subscriber, :failed)
          end
        end
        event.__call_after_hooks__
        raise errors_stack unless errors_stack.empty?
      end

      private

      # @param event [EvilEvents::Core::Events::AbstractEvent]
      # @param subscriber [EvilEvents::Core::Events::Subscriber]
      # @param status [String,Symbol]
      # @return void
      #
      # @since 0.1.1
      def log_activity(event, subscriber, status)
        activity = "EventProcessed(#{event.type})"
        message  = "EVENT_ID: #{event.id} :: " \
                   "STATUS: #{status} :: " \
                   "SUBSCRIBER: #{subscriber.source_object}"

        EvilEvents::Core::ActivityLogger.log(activity: activity, message: message)
      end
    end
  end
end
