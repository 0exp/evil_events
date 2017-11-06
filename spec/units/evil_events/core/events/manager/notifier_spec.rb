# frozen_string_literal: true

describe EvilEvents::Core::Events::Manager::Notifier, :stub_event_system do
  include_context 'event system'

  describe 'notification logic', :null_logger do
    describe '.run' do
      let(:event_class) { build_event_class('test_event') }
      let(:manager)     { build_event_manager(event_class) }
      let(:event)       { event_class.new }

      specify 'absolutely all subscribers should receive an event object' do
        elastic_subscriber = double
        storage_subscriber = double

        manager.observe(elastic_subscriber, :log)
        manager.observe(storage_subscriber, :store)

        expect(elastic_subscriber).to receive(:log).with(event)
        expect(storage_subscriber).to receive(:store).with(event)

        expect { described_class.run(manager, event) }.not_to raise_error
      end

      specify 'absolutely all subscribers should receive an event object ' \
              'despite of the errors in another subscribers (StandardError and higher)' do
        elastic_subscriber = double
        storage_subscriber = double

        super_elegant_error = Class.new(StandardError)

        failing_subscriber = Class.new do
          define_method(:call) { raise super_elegant_error }
        end.new

        manager.observe(elastic_subscriber, :store)
        manager.observe(failing_subscriber, :call)
        manager.observe(storage_subscriber, :push)

        expect(elastic_subscriber).to receive(:store).with(event)
        expect(storage_subscriber).to receive(:push).with(event)

        expect do
          described_class.run(manager, event)
        end.to raise_error(described_class::FailedSubscribersError)
      end

      it 'returns all errors raised by subscribers' do
        super_elegant_error = Class.new(StandardError)
        non_elegant_error   = Class.new(StandardError)

        first_failing_subscriber = Class.new do
          define_method(:call) { |_event| raise super_elegant_error }
        end.new

        second_failing_subscriber = Class.new do
          define_method(:invoke) { |_event| raise non_elegant_error }
        end.new

        manager.observe(first_failing_subscriber, :call)
        manager.observe(second_failing_subscriber, :invoke)

        expect do
          described_class.run(manager, event)
        end.to raise_error(described_class::FailedSubscribersError)

        begin
          described_class.run(manager, event)
        rescue StandardError => error
          expect(error.errors_stack).to contain_exactly(
            an_instance_of(super_elegant_error),
            an_instance_of(non_elegant_error)
          )
        end
      end

      describe 'logging' do
        let(:silent_output)   { StringIO.new }
        let(:silent_logger)   { ::Logger.new(silent_output) }

        before do
          system_config.configure do |config|
            config.logger = silent_logger
          end
        end

        specify 'activity: event type :: message: event id / processing status / subscriber#to_s' do
          expect(silent_output.string).to be_empty

          good_subscriber = ->(event) {}
          bad_subscriber  = ->() {} # will raise ArgumentError

          manager.observe(good_subscriber, :call)
          manager.observe(bad_subscriber, :call)

          begin
            described_class.run(manager, event)
          rescue described_class::FailedSubscribersError => error
            expect(error.errors_stack).to contain_exactly(ArgumentError)
          end

          expect(silent_output.string).to match(
            Regexp.union(
              /\[EvilEvents:EventProcessed\(#{event.type}\)\s/,
              /EVENT_ID:\s#{event.id}\s::\s/,
              /STATUS:\ssuccessful\s::\s/,
              /SUBSCRIBER:\s#{good_subscriber.to_s}/
            )
          )

          expect(silent_output.string).to match(
            Regexp.union(
              /\[EvilEvents:EventProcessed\(#{event.type}\)\s/,
              /EVENT_ID:\s#{event.id}\s::\s/,
              /STATUS:\sfailed\s::\s/,
              /SUBSCRIBER:\s#{bad_subscriber.to_s}/
            )
          )
        end
      end
    end
  end
end
