# frozen_string_literal: true

describe EvilEvents::Core::Events::Notifier::Worker, :stub_event_system, :null_logger do
  specify 'constant compatabilities' do
    expect(described_class::MAIN_THREAD_POLICY).to eq(:main_thread)
    expect(described_class::IGNORANCE_POLICY).to   eq(:ignorance)
    expect(described_class::EXCEPTION_POLICY).to   eq(:exception)

    expect(described_class::Executor::FALLBACK_POLICIES[:exception]).to   eq(:abort)
    expect(described_class::Executor::FALLBACK_POLICIES[:ignorance]).to   eq(:discard)
    expect(described_class::Executor::FALLBACK_POLICIES[:main_thread]).to eq(:caller_runs)
  end

  specify 'instance initialization and instance attributes' do
    # NOTE: EvilEvents::Core::Events::Notifier::Worker::Executor is used internally
    #   Possible executor attributes:
    #     :min_threads      => integer
    #     :max_threads      => integer
    #     :max_queue        => integer
    #     :fallback_policy: => symbol (exception / ignorance / main_thread)

    [
      described_class::MAIN_THREAD_POLICY,
      described_class::IGNORANCE_POLICY,
      described_class::EXCEPTION_POLICY
    ].each do |policy|
      attributes = {
        min_threads:     gen_int(1..10),
        max_threads:     gen_int(10..20),
        max_queue:       gen_int(1..3),
        fallback_policy: policy
      }

      expected_policy  = described_class::Executor::FALLBACK_POLICIES[policy]
      expected_options = attributes.merge(fallback_policy: expected_policy)

      worker = described_class.new(**attributes)

      expect(worker.executor).to be_a(EvilEvents::Core::Events::Notifier::Worker::Executor)
      expect(worker.executor.options).to match(**expected_options)
    end
  end

  describe 'notification process' do
    let(:worker) do
      described_class.new(
        min_threads:     gen_int(1..5),
        max_threads:     gen_int(10..15),
        max_queue:       gen_int(1..3),
        fallback_policy: described_class::MAIN_THREAD_POLICY
      )
    end

    describe '#notify' do
      let(:event_class)  { build_event_class(gen_str(only_letters: true)) }
      let(:event)        { event_class.new }
      let(:subscriber_1) { build_event_subscriber }
      let(:subscriber_2) { build_event_subscriber }
      let(:subscriber_3) { build_event_subscriber }
      let(:manager)      { build_event_manager(event_class) }

      specify 'each subscriber is scheduled to be notified by executor' do
        manager.observe(subscriber_1)
        manager.observe(subscriber_2)
        manager.observe(subscriber_3)

        subscribers_count = manager.subscribers.count

        expect(worker.executor).to receive(:execute).with(
          an_instance_of(EvilEvents::Core::Events::Notifier::Worker::Job)
        ).exactly(subscribers_count).times

        worker.notify(manager, event)
      end

      specify 'corresponding event callbakcs are invoked' do
        expect(event).to receive(:__call_before_hooks__)
        expect(event).to receive(:__call_after_hooks__)

        worker.notify(manager, event)
      end
    end
  end
end
