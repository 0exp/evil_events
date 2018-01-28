# frozen_string_literal: true

# @api private
# since 0.3.0
class EvilEvents::Core::Events::Notifier::Worker::Executor
  # @since 0.3.0
  include EvilEvents::Core::Events::Notifier::Logging

  # @api public
  # @since 0.3.0
  WorkerError = Class.new(EvilEvents::Core::Error)

  # @api public
  # @since 0.3.0
  IncorrectFallbackPolicyError = Class.new(WorkerError)

  # @api public
  # @since 0.3.0
  FALLBACK_POLICIES = {
    exception:   :abort,
    ignorance:   :discard,
    main_thread: :caller_runs
  }.freeze

  # @return [Concurrent::ThreadPoolExecutor]
  # @raise IncorrectFallbackPolicyError
  #
  # @api private
  # @since 0.3.0
  attr_reader :executor

  # @option min_threads [Integer]
  # @option max_threads [Integer]
  # @option max_queue [Integer]
  # @option fallback [Symbol]
  #
  # @api private
  # @since 0.3.0
  def initialize(min_threads:, max_threads:, max_queue:, fallback_policy:)
    raise IncorrectFallbackPolicyError unless FALLBACK_POLICIES[fallback_policy]

    @executor = Concurrent::ThreadPoolExecutor.new(
      min_threads:     min_threads,
      max_threads:     max_threads,
      max_queue:       max_queue,
      fallback_policy: FALLBACK_POLICIES[fallback_policy]
    )
  end

  # @param job [EvilEvents::Core::Events::Notifier::Job]
  # @return void
  #
  # @api private
  # @sicne 0.3.0
  def execute(job)
    Concurrent::Promise.new(executor: executor) do
      job.perform
    end.on_success do
      log_success(job.event, job.subscriber)
    end.on_error do |error|
      event.__call_on_error_hooks__(error)
      log_failure(job.event, job.subscriber)
    end.execute
  end
end
