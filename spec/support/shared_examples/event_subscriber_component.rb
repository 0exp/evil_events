# frozen_string_literal: true

shared_examples 'event subscriber component' do
  describe 'subscriber component behavior' do
    let!(:event_class) { build_event_class('test_event') }
    let!(:another_event_class) { build_event_class('another_test_event') }

    describe '#subscribe_to' do
      it 'can subscribe an object to an event by event class (by Class object)' do
        # subscribe to Event class
        subscribeable.subscribe_to event_class, delegator: :test_call

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :test_call)
        )
        expect(another_event_class.observers).to be_empty

        # subscribe to Event class
        subscribeable.subscribe_to another_event_class, delegator: :uber_call

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :test_call)
        )
        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :uber_call)
        )

        # subscribe to non-event class
        expect do
          subscribeable.subscribe_to gen_class, delegator: :uber_call
        end.to raise_error(EvilEvents::NonManagedEventClassError)
      end

      it 'can subscribe an object to an event by event type field (by String object)' do
        # subscribe to existing event
        subscribeable.subscribe_to event_class.type, delegator: :invoke

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :invoke)
        )
        expect(another_event_class.observers).to be_empty

        # subscribe to existing event
        subscribeable.subscribe_to another_event_class.type, delegator: :invoke

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :invoke)
        )
        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :invoke)
        )

        # subscribe to unexistent event
        expect do
          subscribeable.subscribe_to gen_str, delegator: gen_symb
        end.to raise_error(EvilEvents::NonManagedEventClassError)
      end

      it 'can subscribe to the list of events by event type alias pattern (by Regexp object)' do
        # subscribe to test_event
        subscribeable.subscribe_to /\Atest_[a-z]+\z/i, delegator: :process

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :process)
        )
        expect(another_event_class.observers).to be_empty

        subscribeable.subscribe_to /\Aanother_.+\z/i, delegator: :invoke

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :process)
        )
        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :invoke)
        )

        # subscribe to all
        subscribeable.subscribe_to /.+/, delegator: :call

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :process),
          have_attributes(source_object: subscribeable, delegator: :call)
        )
        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :invoke),
          have_attributes(source_object: subscribeable, delegator: :call)
        )

        # subscribe to nothing
        subscribeable.subscribe_to /#{gen_str}/, delegator: gen_symb

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :process),
          have_attributes(source_object: subscribeable, delegator: :call)
        )
        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :invoke),
          have_attributes(source_object: subscribeable, delegator: :call)
        )
      end

      it 'can subscribe to the list of events by conditional proc (by Proc object)' do
        expect(event_class.observers).to be_empty
        expect(another_event_class.observers).to be_empty

        # true for all even types
        subscribeable.subscribe_to ->(event_type) { event_type.match(/.+/) }, delegator: :boot

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        # false for all event types
        subscribeable.subscribe_to ->(_event_type) { false }

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        # true for test_event only
        subscribeable.subscribe_to ->(event_type) { event_type == 'test_event' }

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot),
          have_attributes(source_object: subscribeable, delegator: :call)
        )

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        # true for another_test_event only
        subscribeable.subscribe_to ->(event_type) { event_type == 'another_test_event' }

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot),
          have_attributes(source_object: subscribeable, delegator: :call)
        )

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot),
          have_attributes(source_object: subscribeable, delegator: :call)
        )
      end

      it 'delegator: can subscribe with globally preconfigured default delegator' do
        global_delegator = gen_symb(only_letters: true)

        EvilEvents::Core::Bootstrap[:config].configure do |config|
          config.subscriber.default_delegator = global_delegator
        end

        expect do
          subscribeable.subscribe_to event_class
        end.to change { event_class.observers.size }.from(0).to(1)

        expect(event_class.observers.last.delegator).to eq(global_delegator)
      end

      it 'raises ArgumentError for non-string/non-class event type argument' do
        expect do
          subscribeable.subscribe_to event_class.new
        end.to raise_error(EvilEvents::ArgumentError)

        expect(event_class.observers).to be_empty
      end

      it 'raises non-managed-error when the event class is not registered without side effects' do
        expect do
          subscribeable.subscribe_to BasicObject
        end.to raise_error(EvilEvents::NonManagedEventClassError)
        expect(event_class.observers).to be_empty
      end
    end
  end
end
