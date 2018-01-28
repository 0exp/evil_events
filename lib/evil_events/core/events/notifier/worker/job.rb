# frozen_string_literal: true

# @api private
# since 0.3.0
class EvilEvents::Core::Events::Notifier::Worker::Job
  # @return [EvilEvents::Core::Events::Subscriber]
  #
  # @api private
  # @since 0.3.0
  attr_reader :subscriber

  # @return [EvilEvents::Core::Events::AbstractEvent]
  #
  # @api private
  # @since 0.3.0
  attr_reader :event

  # @param event [EvilEvents::Core::Events::AbstractEvent]
  # @param subscriber [EvilEvents::Core::Events::Subscriber]
  #
  # @api private
  # @since 0.3.0
  def initialize(event, subscriber)
    @event = event
    @subscriber = subscriber
  end

  # @return void
  #
  # @api private
  # @since 0.3.0
  def perform
    subscriber.notify(event)
  end
end
