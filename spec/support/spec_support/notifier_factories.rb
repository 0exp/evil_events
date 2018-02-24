# frozen_string_literal: true

module SpecSupport::NotifierFactories
  module_function

  def build_job(event, subscriber)
    EvilEvents::Core::Events::Notifier::Worker::Job.new(event, subscriber)
  end

  def build_failing_job_stub(event = build_event_class.new, &subscriber_logic)
    subscriber = build_event_subscriber(failing: true, &subscriber_logic)

    build_job(event, subscriber)
  end

  def build_successful_job_stub(event = build_event_class.new, &subscriber_logic)
    subscriber = build_event_subscriber(&subscriber_logic)

    build_job(event, subscriber)
  end

  def build_job_executor(min_threads: 1, max_threads: 3, max_queue: 2, fallback_policy: :exception)
    EvilEvents::Core::Events::Notifier::Worker::Executor.new(
      min_threads:     min_threads,
      max_threads:     max_threads,
      max_queue:       max_queue,
      fallback_policy: fallback_policy
    )
  end
end
