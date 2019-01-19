# frozen_string_literal: true

# @api private
# since 0.3.0
class EvilEvents::Core::Events::Notifier::Worker::Executor
  # @since 0.3.0
  include EvilEvents::Core::Events::Notifier::Logging

  # @api public
  # @since 0.3.0
  FALLBACK_POLICIES = {
    exception:   :abort,
    ignorance:   :discard,
    main_thread: :caller_runs
  }.freeze

  # @return [Concurrent::ThreadPoolExecutor]
  #
  # @api private
  # @since 0.3.0
  attr_reader :raw_executor

  # @return [Hash]
  #
  # @api private
  # @since 0.3.0
  attr_reader :options

  # @option min_threads [Integer]
  # @option max_threads [Integer]
  # @option max_queue [Integer]
  # @option fallback_policy [Symbol]
  # @raise [EvilEvents::IncorrectFallbackPolicyError]
  #
  # @api private
  # @since 0.3.0
  def initialize(min_threads:, max_threads:, max_queue:, fallback_policy:)
    raise EvilEvents::IncorrectFallbackPolicyError unless FALLBACK_POLICIES[fallback_policy]

    @options = {
      min_threads:     min_threads,
      max_threads:     max_threads,
      max_queue:       max_queue,
      fallback_policy: FALLBACK_POLICIES[fallback_policy]
    }.freeze

    initialize_raw_executor!(**@options)
  end

  # @param job [EvilEvents::Core::Events::Notifier::Job]
  # @raise [EvilEvents::WorkerDisabledOrBusyError]
  # @return [Concurrent::Promise]
  #
  # @api private
  # @sicne 0.3.0
  def execute(job)
    Concurrent::Promise.new(executor: raw_executor) do
      job.perform
    end.on_success do
      log_success(job.event, job.subscriber)
    end.on_error do |error|
      log_failure(job.event, job.subscriber)
      job.event.__call_on_error_hooks__(error)
    end.execute
  rescue Concurrent::RejectedExecutionError
    raise EvilEvents::WorkerDisabledOrBusyError
  end

  # @return void
  #
  # @api private
  # @since 0.3.0
  def shutdown!
    raw_executor.shutdown
    raw_executor.wait_for_termination
  end

  # @return void
  #
  # @api private
  # @since 0.3.0
  def restart!
    shutdown!
    initialize_raw_executor!(**options)
  end

  private

  # @option min_threads [Integer]
  # @option max_threads [Integer]
  # @option max_queue [Integer]
  # @option fallback_policy [Symbol]
  # @return [Concurrent::ThreadPoolExecutor]
  #
  # @api private
  # @since 0.3.0
  def initialize_raw_executor!(**options)
    @raw_executor = Concurrent::ThreadPoolExecutor.new(**options)
  end
end
