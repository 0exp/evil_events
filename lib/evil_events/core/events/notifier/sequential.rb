# frozen_string_literal: true

module EvilEvents::Core::Events::Notifier
  # @api private
  # @since 0.3.0
  class Sequential < Abstract
    # @since 0.3.0
    include Logging

    # @param manager [EvilEvents::Core::Events::Manager]
    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [EvilEvents::FailedNotifiedSubscribersError]
    # @return void
    #
    # @api private
    # @since 0.3.0
    def notify(manager, event)
      errors_stack = EvilEvents::FailedNotifiedSubscribersError.new

      event.__call_before_hooks__

      manager.subscribers.each do |subscriber|
        begin
          subscriber.notify(event)

          log_success(event, subscriber)
        rescue StandardError => error
          event.__call_on_error_hooks__(error)

          errors_stack << error

          log_failure(event, subscriber)
        end
      end

      event.__call_after_hooks__

      raise errors_stack unless errors_stack.empty?
    end
  end
end
