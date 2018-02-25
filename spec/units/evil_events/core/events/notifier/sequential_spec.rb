# frozen_string_literal: true

describe EvilEvents::Core::Events::Notifier::Sequential, :stub_event_system do
  describe 'common notifier interface' do
    it_behaves_like 'notifier logging interface' do
      let(:loggable) { described_class.new }
    end

    it_behaves_like 'notifier callbacks invokation interface' do
      let(:notifier) { described_class.new }
    end
  end

  describe 'notification logic', :null_logger do
    let(:event_class)   { build_event_class('test_event') }
    let(:event_manager) { build_event_manager(event_class) }
    let(:event)         { event_class.new }
    let(:notifier)      { described_class.new }

    describe '#notify' do
      specify 'absolutely all subscribers receives an event object' do
        elastic_subscriber = double
        storage_subscriber = double

        event_manager.observe(elastic_subscriber, :log)
        event_manager.observe(storage_subscriber, :store)

        expect(elastic_subscriber).to receive(:log).with(event)
        expect(storage_subscriber).to receive(:store).with(event)

        expect { notifier.notify(event_manager, event) }.not_to raise_error
      end

      specify 'absolutely all subscribers should receive an event object ' \
              'despite of the errors in another subscribers (StandardError or higher)' do
        elastic_subscriber = double
        storage_subscriber = double

        super_elegant_error = Class.new(StandardError)

        failing_subscriber = Class.new do
          define_method(:call) { raise super_elegant_error }
        end

        event_manager.observe(elastic_subscriber, :store)
        event_manager.observe(storage_subscriber, :push)
        event_manager.observe(failing_subscriber, :call)

        expect(elastic_subscriber).to receive(:store).with(event)
        expect(storage_subscriber).to receive(:push).with(event)

        expect { notifier.notify(event_manager, event) }.to raise_error(
          EvilEvents::Core::Events::Notifier::FailedSubscribersError
        )
      end

      specify 'returns all errors raised by subscribers' do
        super_elegant_error = Class.new(StandardError)
        non_elegant_error   = Class.new(StandardError)

        first_failing_subscriber = Class.new do
          define_method(:call) { |_event| raise super_elegant_error }
        end.new

        second_failing_subscriber = Class.new do
          define_method(:invoke) { |_event| raise non_elegant_error }
        end.new

        event_manager.observe(first_failing_subscriber, :call)
        event_manager.observe(second_failing_subscriber, :invoke)

        expect { notifier.notify(event_manager, event) }.to raise_error(
          EvilEvents::Core::Events::Notifier::FailedSubscribersError
        )

        begin
          notifier.notify(event_manager, event)
        rescue StandardError => error
          expect(error.errors_stack).to contain_exactly(
            an_instance_of(super_elegant_error),
            an_instance_of(non_elegant_error)
          )
        end
      end
    end
  end
end
