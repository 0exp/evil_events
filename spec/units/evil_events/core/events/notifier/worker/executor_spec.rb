# frozen_string_literal: true

describe EvilEvents::Core::Events::Notifier::Worker::Executor, :stub_event_system do
  specify 'constant compatability' do
    expect(described_class::FALLBACK_POLICIES[:exception]).to   eq(:abort)
    expect(described_class::FALLBACK_POLICIES[:ignorance]).to   eq(:discard)
    expect(described_class::FALLBACK_POLICIES[:main_thread]).to eq(:caller_runs)
  end

  describe 'instantiation' do
    specify 'concurrent executor initialization and instance options' do
      # supported attributes (corresponding to the Concurrent::ThreadPool specification):
      #   :exception   => (:abort)
      #   :ignorance   => (:discard)
      #   :main_thread => (:caller_runs)

      { exception: :abort,
        ignorance: :discard,
        main_thread: :caller_runs
      }.each_pair do |policy, concurrent_policy|
        expect do
          min_threads = gen_int(1..10)
          max_threads = gen_int(10..20)
          max_queue   = gen_int(1..5)

          executor = described_class.new(
            min_threads:     min_threads,
            max_threads:     max_threads,
            max_queue:       max_queue,
            fallback_policy: policy
          )

          expect(executor.raw_executor).to have_attributes({
            min_length:      min_threads,
            max_length:      max_threads,
            max_queue:       max_queue,
            fallback_policy: concurrent_policy
          })

          expect(executor.options).to match(
            min_threads:     min_threads,
            max_threads:     max_threads,
            max_queue:       max_queue,
            fallback_policy: concurrent_policy
          )
        end.not_to raise_error
      end
    end

    it 'fails on incorret fallback policy' do
      expect do
        described_class.new(
          min_threads:     gen_int(1..10),
          max_threads:     gen_int(10..20),
          max_queue:       gen_int(1..5),
          fallback_policy: gen_symb(only_letters: true)
        )
      end.to raise_error(described_class::IncorrectFallbackPolicyError)
    end
  end

  describe 'common logic' do
    let(:event_class)    { build_event_class }
    let(:event)          { event_class.new }
    let(:failing_job)    { build_failing_job_stub(event) }
    let(:successful_job) { build_successful_job_stub(event) }
    let(:executor)       { build_job_executor }
    let(:silent_output)  { StringIO.new }
    let(:silent_logger)  { Logger.new(silent_output) }

    before do
      EvilEvents::Config.configure do |config|
        config.logger = silent_logger
      end
    end

    describe 'shutting down' do
      specify '#shutdown! prevents exectution of new jobs with exception' do
        executor.shutdown!

        expect do
          executor.execute(successful_job)
        end.to raise_error(described_class::WorkerDisabledOrBusyError)

        expect(silent_output.string).to be_empty
      end

      specify '#restart! reinitializes internal executor' do
        expect do
          promise = executor.execute(successful_job)
          loop { break if promise.complete? }
          promise = executor.execute(failing_job)
          loop { break if promise.complete? }

          executor.shutdown!
          executor.restart!

          promise = executor.execute(successful_job)
          loop { break if promise.complete? }
          promise = executor.execute(failing_job)
          loop { break if promise.complete? }
        end.not_to raise_error
      end
    end

    describe 'job execution' do
      specify 'successful execution' do
        promise = executor.execute(successful_job)
        loop { break if promise.complete? }

        expect(silent_output.string).to match(
          Regexp.union(
            /\[EvilEvents::EventProcessed\(#{event.type}\)\]\s/,
            /EVENT_ID:\s#{event.id}\s::\s/,
            /STATUS:\ssuccessful\s::\s/,
            /SUBSCRIBER:\s#{successful_job.subscriber.source_object.to_s}/
          )
        )
      end

      specify 'failing execution' do
        error_callback_hook = { event: nil, error: nil }

        event_class.on_error(->(event, error) {
          error_callback_hook[:event] = event
          error_callback_hook[:error] = error
        })

        promise = executor.execute(failing_job)
        loop { break if promise.complete? }

        expect(silent_output.string).to match(
          Regexp.union(
            /\[EvilEvents::EventProcessed\(#{event.type}\)\]\s/,
            /EVENT_ID:\s#{event.id}\s::\s/,
            /STATUS:\sfailed\s::\s/,
            /SUBSCRIBER:\s#{successful_job.subscriber.source_object.to_s}/
          )
        )

        expect(error_callback_hook[:event]).to eq(event)
        expect(error_callback_hook[:error]).to be_a(
          SpecSupport::EventFactories::EventSubscriberError
        )
      end
    end
  end
end
