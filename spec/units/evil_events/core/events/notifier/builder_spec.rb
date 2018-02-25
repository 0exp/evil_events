# frozen_string_literal: true

describe EvilEvents::Core::Events::Notifier::Builder, :stub_event_system do
  include_context 'event system'

  describe '#build_notifier!' do
    describe 'unregistered notifier type build' do
      before do
        system_config.configure do |config|
          config.notifier.type = gen_symb(only_letters: true)
        end
      end

      specify 'unregistered notifier type' do
        expect do
          described_class.build_notifier!
        end.to raise_error(EvilEvents::UnknownNotifierTypeError)
      end
    end

    describe 'sequential notifier build' do
      before do
        system_config.configure do |config|
          config.notifier.type = :sequential
        end
      end

      specify 'sequential notifier' do
        notifier = described_class.build_notifier!
        expect(notifier).to be_a(EvilEvents::Core::Events::Notifier::Sequential)
      end
    end

    describe 'worker notifier build' do
      let(:worker_fallback_policies) do
        EvilEvents::Core::Events::Notifier::Worker::Executor::FALLBACK_POLICIES
      end

      before do
        system_config.configure do |config|
          config.notifier.type = :worker
        end
      end

      specify 'worker notifier with default config' do
        notifier = described_class.build_notifier!
        expect(notifier).to be_a(EvilEvents::Core::Events::Notifier::Worker)

        concurrent_executor = notifier.executor.raw_executor
        worker_config = system_config.notifier.worker.to_h
        default_executor_options = {
          min_length:      worker_config[:min_threads],
          max_length:      worker_config[:max_threads],
          max_queue:       worker_config[:max_queue],
          fallback_policy: worker_fallback_policies[worker_config[:fallback_policy]]
        }
        expect(concurrent_executor).to have_attributes(**default_executor_options)
      end

      specify 'worker notifier with custom config' do
        custom_worker_options = {
          min_threads:     gen_int(0..5),
          max_threads:     gen_int(5..10),
          max_queue:       gen_int(1..1_000),
          fallback_policy: worker_fallback_policies.keys.sample
        }

        system_config.configure do |config|
          config.notifier.worker.min_threads     = custom_worker_options[:min_threads]
          config.notifier.worker.max_threads     = custom_worker_options[:max_threads]
          config.notifier.worker.max_queue       = custom_worker_options[:max_queue]
          config.notifier.worker.fallback_policy = custom_worker_options[:fallback_policy]
        end

        notifier = described_class.build_notifier!
        expect(notifier).to be_an_instance_of(EvilEvents::Core::Events::Notifier::Worker)

        concurrent_executor = notifier.executor.raw_executor
        default_executor_options = {
          min_length:      custom_worker_options[:min_threads],
          max_length:      custom_worker_options[:max_threads],
          max_queue:       custom_worker_options[:max_queue],
          fallback_policy: worker_fallback_policies[custom_worker_options[:fallback_policy]]
        }
        expect(concurrent_executor).to have_attributes(**default_executor_options)
      end
    end
  end
end
