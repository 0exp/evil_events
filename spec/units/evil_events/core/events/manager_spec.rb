# frozen_string_literal: true

describe EvilEvents::Core::Events::Manager, :stub_event_system, :null_logger do
  include_context 'event system'

  specify 'instantiation requirements' do
    simple_event_class  = build_event_class('dropped')
    another_event_class = build_event_class('written')

    manager = described_class.new(simple_event_class)
    expect(manager.event_class).to eq(simple_event_class)
    expect(manager.subscribers).to be_empty

    manager = described_class.new(another_event_class)
    expect(manager.event_class).to eq(another_event_class)
    expect(manager.subscribers).to be_empty
  end

  describe 'public instance interface' do
    describe 'interactions with serviced event' do
      let!(:first_event_class)  { build_event_class('money_in') }
      let!(:second_event_class) { build_event_class('money_out') }

      describe '#event_class' do
        it 'returns serviced event class' do
          manager = described_class.new(first_event_class)
          expect(manager.event_class).to eq(first_event_class)

          manager = described_class.new(second_event_class)
          expect(manager.event_class).to eq(second_event_class)
        end
      end

      describe '#event_type' do
        it 'returns a string alias of registered event class (#type)' do
          manager = described_class.new(first_event_class)
          expect(manager.event_type).to eq(first_event_class.type)

          manager = described_class.new(second_event_class)
          expect(manager.event_type).to eq(second_event_class.type)
        end
      end
    end

    describe 'subscription interactions' do
      let(:event_class) { build_event_class('test_event') }
      let(:manager)     { described_class.new(event_class) }

      describe '#subscribers' do
        it 'returns all registered subscribers at this moment wrapped with delegating class' do
          first_subscriber  = double
          second_subscriber = double

          manager.observe(first_subscriber)
          expect(manager.subscribers.registered?(first_subscriber)).to eq(true)
          expect(manager.subscribers.registered?(second_subscriber)).to eq(false)

          manager.observe(second_subscriber)
          expect(manager.subscribers.registered?(first_subscriber)).to eq(true)
          expect(manager.subscribers.registered?(second_subscriber)).to eq(true)

          expect(manager.subscribers).to all(be_an(EvilEvents::Core::Events::Subscriber))
        end
      end

      describe '#source_subscribers' do
        it 'returns all initial objects which registered to the serviced event' do
          first_subscriber  = double
          second_subscriber = double

          expect(manager.subscribers.sources).to be_empty

          manager.observe(first_subscriber)
          expect(manager.subscribers.sources).to contain_exactly(first_subscriber)

          manager.observe(second_subscriber)
          expect(manager.subscribers.sources).to contain_exactly(
            first_subscriber, second_subscriber
          )
        end
      end

      describe '#observe' do
        it 'registers received object to the serviced event with required delegator method' do
          first_subscriber  = double
          second_subscriber = double

          manager.observe(first_subscriber,  :process)
          manager.observe(second_subscriber, :invoke)

          fs_wrapper = manager.subscribers.wrapper_of(first_subscriber)
          ss_wrapper = manager.subscribers.wrapper_of(second_subscriber)

          expect(fs_wrapper.delegator).to eq(:process)
          expect(ss_wrapper.delegator).to eq(:invoke)
        end

        it 'delegation method can be nil/symbol/string primivite only' do
          expect { manager.observe(double, nil)    }.not_to raise_exception
          expect { manager.observe(double, 'call') }.not_to raise_exception
          expect { manager.observe(double, :call)  }.not_to raise_exception
          expect { manager.observe(double)         }.not_to raise_exception

          expect { manager.observe(double, 123) }.to(
            raise_error(described_class::InvalidDelegatorTypeError)
          )
          expect { manager.observe(double, Object.new) }.to(
            raise_error(described_class::InvalidDelegatorTypeError)
          )
        end

        it 'delegation method can be skipped: system will use globally predefined delegator' do
          first_subscriber  = double
          second_subscriber = double

          system_config.configure do |config|
            config.subscriber.default_delegator = :process
          end

          manager.observe(first_subscriber)
          subscriber_wrapper = manager.subscribers.wrapper_of(first_subscriber)
          expect(subscriber_wrapper.delegator).to eq(:process)

          system_config.configure do |config|
            config.subscriber.default_delegator = :invoke
          end

          manager.observe(second_subscriber)
          subscriber_wrapper = manager.subscribers.wrapper_of(second_subscriber)
          expect(subscriber_wrapper.delegator).to eq(:invoke)
        end
      end
    end

    describe 'notification process' do
      let(:registered_event_class)   { build_event_class('overwatched') }
      let(:unregistered_event_class) { build_event_class('hyperwatched') }
      let(:manager)                  { described_class.new(registered_event_class) }

      describe '#notify' do
        subject(:notify) { manager.notify(event) }

        let(:first_subscriber)  { ->(event) {} }
        let(:second_subscriber) { ->(event) {} }
        let(:third_subscriber)  { Class.new { def process_event(event); end }.new }

        context 'when passed attribute is an instance of registered event class' do
          let(:event) { registered_event_class.new }

          it 'all subscribers receives event object via defined delegator' do
            manager.observe(first_subscriber,  :call)
            manager.observe(second_subscriber, :call)
            manager.observe(third_subscriber,  :process_event)

            expect(first_subscriber).to  receive(:call).with(event)
            expect(second_subscriber).to receive(:call).with(event)
            expect(third_subscriber).to  receive(:process_event).with(event)

            notify
          end
        end

        context 'when passed attribute isnt an instance of registered event class' do
          let(:event) { unregistered_event_class.new }

          it 'fails with appropriate error' do
            expect(first_subscriber).not_to  receive(:call)
            expect(second_subscriber).not_to receive(:call)
            expect(third_subscriber).not_to  receive(:process_event)

            expect { notify }.to raise_error(described_class::InconsistentEventClassError)
          end
        end
      end
    end
  end
end
