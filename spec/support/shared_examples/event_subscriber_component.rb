# frozen_string_literal: true

shared_examples 'event subscriber component' do
  describe 'subscriber component behavior' do
    describe '#subscribe_to_scope' do
      let!(:deposit_event) { build_event_class('deposit') }
      let!(:deposit_created_event) { build_event_class('deposit.created') }
      let!(:deposit_created_tomorrow_event) { build_event_class('deposit.created.tomorrow') }
      let!(:user_event) { build_event_class('user') }
      let!(:user_created_event) { build_event_class('user.created') }
      let!(:user_created_yesterday_event) { build_event_class('user.created.yesterday') }

      it 'can subscribe an object to a list of events with passed event routing-based pattern' do
        delegator = gen_symb(only_letters: true)
        # subscribe to 'user.created' and 'user.created.yesterday' events
        subscribeable.subscribe_to_scope 'user.created.#', delegator: delegator

        expect(deposit_event.observers).to be_empty
        expect(deposit_created_event.observers).to be_empty
        expect(deposit_created_tomorrow_event.observers).to be_empty
        expect(user_event.observers).to be_empty
        expect(user_created_yesterday_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_created_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )

        # subscribe to 'desposit', 'deposit.created' and 'deposit.created.tomorrow' events
        subscribeable.subscribe_to_scope 'deposit.#', delegator: delegator

        expect(user_event.observers).to be_empty
        expect(deposit_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(deposit_created_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(deposit_created_tomorrow_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_created_yesterday_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_created_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )

        # subscribe to 'user' event only
        subscribeable.subscribe_to_scope 'user', delegator: delegator
        expect(deposit_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(deposit_created_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(deposit_created_tomorrow_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_created_yesterday_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_created_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )

        # subscribe to nothing
        subscribeable.subscribe_to_scope gen_str, delegator: delegator
        expect(deposit_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(deposit_created_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(deposit_created_tomorrow_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_created_yesterday_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
        expect(user_created_event.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: delegator)
        )
      end
    end

    describe '#subscribe_to' do
      let!(:event_class) { build_event_class('test_event') }
      let!(:another_event_class) { build_event_class('another_test_event') }

      it 'can subscribe an object to an event with an event class (by Class object)' do
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

      it 'can subscribe an object to an event with event type field (by String object)' do
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

      it 'can subscribe to the list of events with event type alias pattern (by Regexp object)' do
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

      it 'can subscribe to the list of events with conditional proc (by Proc object)' do
        expect(event_class.observers).to be_empty
        expect(another_event_class.observers).to be_empty

        # true for all even types
        subscribeable.subscribe_to -> (event_type) { event_type.match(/.+/) }, delegator: :boot

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        # false for all event types
        subscribeable.subscribe_to -> (_event_type) { false }

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        # true for test_event only
        subscribeable.subscribe_to -> (event_type) { event_type == 'test_event' }

        expect(event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot),
          have_attributes(source_object: subscribeable, delegator: :call)
        )

        expect(another_event_class.observers).to contain_exactly(
          have_attributes(source_object: subscribeable, delegator: :boot)
        )

        # true for another_test_event only
        subscribeable.subscribe_to -> (event_type) { event_type == 'another_test_event' }

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

      it 'raises non-managed-error (without side effects) when the event class is not registered' do
        expect do
          subscribeable.subscribe_to BasicObject
        end.to raise_error(EvilEvents::NonManagedEventClassError)
        expect(event_class.observers).to be_empty
      end

      it 'raises non-managed-error (without side effects) when ' \
         'an event with passed type isnt registered' do
        expect do
          subscribeable.subscribe_to gen_str
        end.to raise_error(EvilEvents::NonManagedEventClassError)
        expect(event_class.observers).to be_empty
      end
    end
  end
end
