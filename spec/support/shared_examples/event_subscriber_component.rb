# frozen_string_literal: true

shared_context 'event subscriber component' do
  describe 'subscriber component behavior' do
    let!(:event_class) { build_event_class('test_event') }

    describe '#subscribe_to' do
      it 'can subscribe an object to an event by an event class (by Class object)' do
        expect do
          subscribeable.subscribe_to event_class, delegator: :test_call
        end.to change { event_class.observers.size }.from(0).to(1)

        # fetch subcriber abstraction
        wrapped_subscriber = event_class.observers.first
        # get source subscriber object
        source_subscriber  = wrapped_subscriber.source_object

        expect(source_subscriber).to eq(subscribeable)
        expect(wrapped_subscriber.delegator).to eq(:test_call)
      end

      it 'can subscribe an object to an event by an event type field (by String object)' do
        expect do
          subscribeable.subscribe_to event_class.type, delegator: :invoke
        end.to change { event_class.observers.size }.from(0).to(1)

        # fetch subcriber abstraction
        wrapped_subscriber = event_class.observers.first
        # get source subscriber object
        source_subscriber  = wrapped_subscriber.source_object

        expect(source_subscriber).to eq(subscribeable)
        expect(wrapped_subscriber.delegator).to eq(:invoke)
      end

      it 'can subscribe with globally preconfigured default delegator' do
        EvilEvents::Core::Bootstrap[:config].configure do |config|
          config.subscriber.default_delegator = :subscribeable_test_call
        end

        expect do
          subscribeable.subscribe_to event_class
        end.to change { event_class.observers.size }.from(0).to(1)

        expect(event_class.observers.last.delegator).to eq(:subscribeable_test_call)
      end

      it 'raises ArgumentError for non-string/non-class event type argument' do
        expect { subscribeable.subscribe_to event_class.new }.to raise_error(ArgumentError)
        expect(event_class.observers).to be_empty
      end

      it 'raises non-managed-error when the event class is not registered without side effects' do
        expect do
          subscribeable.subscribe_to BasicObject
        end.to raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
        expect(event_class.observers).to be_empty
      end
    end
  end
end
