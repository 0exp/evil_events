# frozen_string_literal: true

module EvilEvents::Core::Events::Notifier
  # @api private
  # @since 0.3.0
  class Worker < Abstract
    # @api public
    # @since 0.3.0
    MAIN_THREAD_POLICY = :main_thread

    # @api public
    # @since 0.3.0
    IGNORANCE_POLICY = :ignorance

    # @api public
    # @since 0.3.0
    EXCEPTION_POLICY = :exception

    # @return [EvilEvents::Core::Events::Notifier::Worker::Executor]
    #
    # @api private
    # @since 0.3.0
    attr_reader :executor

    # @option min_threads [Integer]
    # @option max_threads [Integer]
    # @option max_queue [Integer]
    # @option fallback_policy [Symbol]
    #
    # @see EvilEvents::Core::Events::Notifier::Worker::Executor
    #
    # @api private
    # @since 0.3.0
    def initialize(min_threads:, max_threads:, max_queue:, fallback_policy: MAIN_THREAD_POLICY)
      @executor = Executor.new(
        min_threads:     min_threads,
        max_threads:     max_threads,
        max_queue:       max_queue,
        fallback_policy: fallback_policy
      )
    end

    # @param manager [EvilEvents::Core::Events::Manager]
    # @param event [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.3.0
    def notify(manager, event)
      event.__call_before_hooks__
      manager.subscribers.each { |subscriber| schedule_job(event, subscriber) }
      event.__call_after_hooks__
    end

    private

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @param subscriber [EvilEvents::Core::Events::Subscriber]
    #
    # @api private
    # @since 0.3.0
    def schedule_job(event, subscriber)
      executor.execute(Job.new(event, subscriber))
    end
  end
end
