# frozen_string_literal: true

# TODO: dry this suite
describe EvilEvents::Core::System::EventManager, :stub_event_system do
  let(:event_manager)    { described_class.new }
  let(:manager_registry) { event_manager.manager_registry }

  let(:event_class)         { build_abstract_event_class('test_event') }
  let(:another_event_class) { build_abstract_event_class('another_test_event') }

  describe '#manager_registry' do
    it 'returns an instance of the corresponding logical element with appropriate initial state' do
      expect(event_manager.manager_registry).to be_a(EvilEvents::Core::Events::ManagerRegistry)
      expect(event_manager.manager_registry).to be_empty
    end
  end

  describe 'event/event manager registering/resolving' do
    describe '#register_event_class' do
      context 'when passed event class is not registered' do
        it 'registers passed event class in the internal manager registry' do
          expect(manager_registry).to be_empty
          expect(manager_registry.managed_event?(event_class)).to eq(false)
          expect(manager_registry.size).to eq(0)

          event_manager.register_event_class(event_class)

          expect(manager_registry).not_to be_empty
          expect(manager_registry.managed_event?(event_class)).to eq(true)
          expect(manager_registry.size).to eq(1)
        end
      end

      context 'when passed event class is registered' do
        before { event_manager.register_event_class(event_class) }

        it 're-registrates passed event class in the internal manager registry' do
          expect do
            event_manager.register_event_class(event_class)
          end.not_to(change { manager_registry.size })
        end
      end
    end

    describe '#unregister_event_class' do
      before do
        event_manager.register_event_class(event_class)
        event_manager.register_event_class(another_event_class)
      end

      context 'when passed event class is registered' do
        it 'deletes event manager of passed event class from internal manager registry' do
          expect(manager_registry).not_to be_empty
          expect(manager_registry.managed_event?(event_class)).to eq(true)
          expect(manager_registry.managed_event?(another_event_class)).to eq(true)
          expect(manager_registry.size).to eq(2)

          event_manager.unregister_event_class(event_class)

          expect(manager_registry).not_to be_empty
          expect(manager_registry.managed_event?(event_class)).to eq(false)
          expect(manager_registry.managed_event?(another_event_class)).to eq(true)
          expect(manager_registry.size).to eq(1)

          event_manager.unregister_event_class(another_event_class)

          expect(manager_registry).to be_empty
          expect(manager_registry.managed_event?(event_class)).to eq(false)
          expect(manager_registry.managed_event?(another_event_class)).to eq(false)
          expect(manager_registry.size).to eq(0)
        end
      end

      context 'when passed event class isnt registered' do
        it 'doing nothing' do
          event_manager.unregister_event_class(event_class) # exists
          event_manager.unregister_event_class(event_class) # doesnt exist

          expect(manager_registry.size).to eq(1)
          expect(manager_registry.managed_event?(another_event_class)).to eq(true)
        end
      end
    end

    describe '#registered_events' do
      it 'returns a list of created event classes in event_class#type_alias => event_class form' do
        expect(event_manager.registered_events).to eq({})

        event_manager.register_event_class(event_class)

        expect(event_manager.registered_events).to match(
          event_class.type => event_class
        )

        event_manager.register_event_class(another_event_class)

        expect(event_manager.registered_events).to match(
          event_class.type => event_class,
          another_event_class.type => another_event_class
        )

        event_manager.unregister_event_class(event_class)

        expect(event_manager.registered_events).to match(
          another_event_class.type => another_event_class
        )

        event_manager.unregister_event_class(another_event_class)

        expect(event_manager.registered_events).to eq({})
      end
    end

    describe '#resolve_event_object' do
      context 'when required event class is registered' do
        let(:event_class) do
          build_event_class('super_called') do
            payload :kek
            payload :pek
            metadata :lel
          end
        end

        before { event_manager.register_event_class(event_class) }

        it 'reconstructs an event object by the passed event attributes (type and attrs)' do
          event = event_manager.resolve_event_object(
            'super_called', payload: { kek: 'lol', pek: 123 }, metadata: { lel: 'test' }
          )

          expect(event).to be_a(event_class)
          expect(event).to have_attributes(
            type: 'super_called',
            payload: match(kek: 'lol', pek: 123),
            metadata: match(lel: 'test')
          )
        end
      end

      context 'when required event class is not registered' do
        it 'fails with corresponding error' do
          expect do
            event_manager.resolve_event_object(
              'sper_called',
              payload: { kek: 'test', pek: nil },
              metadata: { lel: 'bah' }
            )
          end.to raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
        end
      end
    end

    describe '#manager_of_event' do
      let(:event) { event_class.new }

      context 'when passed event is registered' do
        before { event_manager.register_event_class(event_class) }

        it 'returns the manager object of the passed event' do
          manager = event_manager.manager_of_event(event)
          expect(manager.event_class).to eq(event_class)
        end
      end

      context 'when passed event is not registered' do
        it 'fails with corresponding error' do
          expect do
            event_manager.manager_of_event(event)
          end.to raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
        end
      end
    end

    describe '#manager_of_event_type' do
      context 'when passed event is registered' do
        before { event_manager.register_event_class(event_class) }

        it 'returns the manager object of the passed event' do
          manager = event_manager.manager_of_event_type(event_class.type)
          expect(manager.event_class).to eq(event_class)
        end
      end

      context 'when passed event is not registered' do
        it 'fails with corresponding error' do
          expect do
            event_manager.manager_of_event_type(event_class.type)
          end.to raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
        end
      end
    end

    describe '#managed_event?' do
      subject { event_manager.managed_event?(event_class) }

      context 'when passed event is registered' do
        before { event_manager.register_event_class(event_class) }

        it { is_expected.to eq(true) }
      end

      context 'when passed event is not registered' do
        it { is_expected.to eq(false) }
      end
    end
  end

  describe 'subscription' do
    describe 'subscribe to concrete event' do
      describe '#observe' do
        context 'when required event class is registered' do
          before { event_manager.register_event_class(event_class) }

          it 'subscribes an object to the required event' do
            manager = manager_registry.manager_of_event(event_class)
            subscriber, delegator = (proc {}), gen_symb(only_letters: true)

            event_manager.observe(event_class, subscriber, delegator)

            expect(manager.subscribers.registered?(subscriber)).to eq(true)
            expect(manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)
          end
        end

        context 'when required event class is not registered' do
          it 'fails with corresponding error' do
            expect do
              event_manager.observe(event_class, double, :call)
            end.to raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
          end
        end
      end

      describe '#raw_observe' do
        context 'when required event class is registered' do
          before { event_manager.register_event_class(event_class) }

          it 'subscribes an object to the required event' do
            manager = manager_registry.manager_of_event(event_class)
            subscriber, delegator = (proc {}), gen_symb(only_letters: true)

            event_manager.raw_observe(event_class.type, subscriber, delegator)

            expect(manager.subscribers.registered?(subscriber)).to eq(true)
            expect(manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)
          end
        end

        context 'when required event class is not registered' do
          it 'fails with corresponding error' do
            expect do
              event_manager.raw_observe(event_class.type, double, :call)
            end.to raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
          end
        end
      end
    end

    describe 'subscribe to the list of events' do
      let(:first_manager)  { manager_registry.manager_of_event(event_class) }
      let(:second_manager) { manager_registry.manager_of_event(another_event_class) }

      before do
        event_manager.register_event_class(event_class)
        event_manager.register_event_class(another_event_class)
      end

      describe '#observe_list' do
        it 'subscribes an object to events whose alias is comparable with a pattern' do
          subscriber, delegator = (-> (event) {}), gen_symb(only_letters: true)

          pattern = /#{gen_str}/ # no matches
          event_manager.observe_list(pattern, subscriber, delegator)

          expect(first_manager.subscribers.registered?(subscriber)).to eq(false)
          expect(second_manager.subscribers.registered?(subscriber)).to eq(false)

          pattern = /\Atest_event\z/ # matches with test_event (event_class)
          event_manager.observe_list(pattern, subscriber, delegator)

          expect(first_manager.subscribers.registered?(subscriber)).to eq(true)
          expect(first_manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)
          expect(second_manager.subscribers.registered?(subscriber)).to eq(false)

          pattern = /.+/ # matches with all
          event_manager.observe_list(pattern, subscriber, delegator)

          expect(first_manager.subscribers.registered?(subscriber)).to eq(true)
          expect(second_manager.subscribers.registered?(subscriber)).to eq(true)
          expect(first_manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)
          expect(second_manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)
        end
      end

      describe '#conditional_observe' do
        specify 'condition of alias isnt false/nil ==> subscribes an object to this event' do
          subscriber, delegator = (-> (event) {}), gen_symb(only_letters: true)

          # fail condition => doesnt register
          condition = -> (event_type) { false }
          event_manager.conditional_observe(condition, subscriber, delegator)

          expect(first_manager.subscribers.registered?(subscriber)).to eq(false)
          expect(second_manager.subscribers.registered?(subscriber)).to eq(false)

          # true for another_event_class => subscribes on this
          condition = -> (event_type) { event_type == 'another_test_event' }
          event_manager.conditional_observe(condition, subscriber, delegator)

          expect(first_manager.subscribers.registered?(subscriber)).to eq(false)
          expect(second_manager.subscribers.registered?(subscriber)).to eq(true)
          expect(second_manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)

          # true for all => subscribes on all
          condition = -> (event_type) { event_type.match(/.+/) }
          event_manager.conditional_observe(condition, subscriber, delegator)

          expect(first_manager.subscribers.registered?(subscriber)).to eq(true)
          expect(second_manager.subscribers.registered?(subscriber)).to eq(true)
          expect(first_manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)
          expect(second_manager.subscribers.wrapper_of(subscriber).delegator).to eq(delegator)
        end
      end
    end

    describe '#observers' do
      context 'when passed event class is registered' do
        before { event_manager.register_event_class(event_class) }

        it 'returns subscribers of the passed event class' do
          first_subscriber  = double
          first_delegator   = :invoke
          second_subscriber = double
          second_delegator  = :process

          expect(event_manager.observers(event_class)).to be_empty

          event_manager.observe(event_class, first_subscriber, first_delegator)
          expect(event_manager.observers(event_class)).not_to be_empty
          expect(event_manager.observers(event_class).size).to eq(1)

          expect(event_manager.observers(event_class)).to include(
            have_attributes(
              source_object: first_subscriber,
              delegator: first_delegator
            )
          )

          event_manager.observe(event_class, second_subscriber, second_delegator)
          expect(event_manager.observers(event_class)).not_to be_empty
          expect(event_manager.observers(event_class).size).to eq(2)

          expect(event_manager.observers(event_class)).to include(
            have_attributes(
              source_object: first_subscriber,
              delegator: first_delegator
            )
          )

          expect(event_manager.observers(event_class)).to include(
            have_attributes(
              source_object: second_subscriber,
              delegator: second_delegator
            )
          )
        end
      end

      context 'when passed event class is not registered' do
        it 'fails with corresponding error' do
          expect do
            event_manager.observers(event_class)
          end.to raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
        end
      end
    end
  end
end
