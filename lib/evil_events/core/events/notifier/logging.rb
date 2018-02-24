# frozen_string_literal: true

# @api private
# @since 0.3.0
module EvilEvents::Core::Events::Notifier::Logging
  # @param event [EvilEvents::Core::Events::AbstractEvent]
  # @param subscriber [EvilEvents::Core::Events::Subscriber]
  # @return void
  #
  # @api private
  # @since 0.3.0
  def log_failure(event, subscriber)
    log_activity(event, subscriber, :failed)
  end

  # @param event [EvilEvents::Core::Events::AbstractEvent]
  # @param subscriber [EvilEvents::Core::Events::Subscriber]
  # @return void
  #
  # @api private
  # @since 0.3.0
  def log_success(event, subscriber)
    log_activity(event, subscriber, :successful)
  end

  private

  # @param event [EvilEvents::Core::Events::AbstractEvent]
  # @param subscriber [EvilEvents::Core::Events::Subscriber]
  # @param status [String, Symbol]
  # @return void
  #
  # @api private
  # @since 0.3.0
  def log_activity(event, subscriber, status)
    activity = "EventProcessed(#{event.type})"
    message  = "EVENT_ID: #{event.id} :: " \
               "STATUS: #{status} :: " \
               "SUBSCRIBER: #{subscriber.source_object}"

    EvilEvents::Core::ActivityLogger.log(activity: activity, message: message)
  end
end
