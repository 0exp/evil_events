# frozen_string_literal: true

describe EvilEvents::Core::Events::EventFactory, :stub_event_system do
  include_context 'event system'

  let(:events_namespace)     { EvilEvents::Core::Events }
  let(:extensions_namespace) { events_namespace::EventExtensions }
  let(:manager_registry)     { event_system.event_manager.manager_registry }

  shared_examples 'shared class construction logic' do |construction_method|
    it 'returns a subclass of abstract event class' do
      event_class = described_class.public_send(construction_method, 'overwatched')
      expect(event_class).to be < EvilEvents::Core::Events::AbstractEvent
    end
  end

  describe 'building of abstract event class' do
    describe '.create_abstract_class' do
      include_examples 'shared class construction logic', :create_abstract_class

      specify 'requires event type alias only (string object)' do
        expect do
          described_class.create_abstract_class('user_registered')
        end.not_to raise_error

        expect do
          described_class.create_abstract_class('overwatched', &(proc {}))
        end.not_to raise_error

        expect { described_class.create_abstract_class }.to(
          raise_error(ArgumentError)
        )

        expect { described_class.create_abstract_class('test_event', double) }.to(
          raise_error(ArgumentError)
        )

        expect { described_class.create_abstract_class(double) }.to(
          raise_error(extensions_namespace::TypeAliasing::IncopatibleEventTypeError)
        )

        expect { described_class.create_abstract_class(nil) }.to(
          raise_error(extensions_namespace::TypeAliasing::EventTypeNotDefinedError)
        )
      end

      specify 'passed type alias becomes a type alias of a new created abstract class' do
        abstract_event_class = described_class.create_abstract_class('overwatched')
        expect(abstract_event_class.type).to eq('overwatched')

        abstract_event_class = described_class.create_abstract_class('healed')
        expect(abstract_event_class.type).to eq('healed')
      end

      it 'doesnt registers new created class in manager regestry' do
        described_class.create_abstract_class('destroyed')
        expect(event_system.event_manager.manager_registry).to be_empty

        described_class.create_abstract_class('installed')
        expect(event_system.event_manager.manager_registry).to be_empty
      end

      specify 'descendant of created class automatically registrates in manager registry' do
        abstract_event_class         = described_class.create_abstract_class('created')
        concrete_event_class         = Class.new(abstract_event_class)

        another_abstract_event_class = described_class.create_abstract_class('used')
        another_event_class          = Class.new(another_abstract_event_class)

        [
          [concrete_event_class, 'created'],
          [another_event_class, 'used']
        ].each do |event_class, expected_alias|
          expect(event_class.type).to eq(expected_alias)
          expect(manager_registry.managed_event?(event_class)).to eq(true)
          expect { manager_registry.manager_of_event(event_class) }.not_to raise_error
        end

        expect(manager_registry.size).to eq(2)
      end

      specify 'duplications doesnt affects manager registry and fails with registry error' do
        abstract_event_class   = described_class.create_abstract_class('inherited')
        concrete_event_class   = Class.new(abstract_event_class)
        concrete_event_manager = manager_registry.manager_of_event(concrete_event_class)

        # try to duplicate: run registration hooks again
        expect { Class.new(abstract_event_class) }.to(
          raise_error(events_namespace::ManagerRegistry::AlreadyManagedEventClassError)
        )
        # try again
        expect { Class.new(abstract_event_class) }.to(
          raise_error(events_namespace::ManagerRegistry::AlreadyManagedEventClassError)
        )

        expect(manager_registry.managed_event?(concrete_event_class)).to eq(true)
        expect(manager_registry).to include(concrete_event_manager)
        expect(manager_registry.size).to eq(1)
      end
    end
  end

  describe 'building of concrete event class' do
    describe '.create_class' do
      include_examples 'shared class construction logic', :create_class

      it 'creates a concrete event class with defined type alias and registered manager' do
        concrete_event_class = described_class.create_class('overwatched')
        another_event_class  = described_class.create_class('covered')

        [
          [concrete_event_class, 'overwatched'],
          [another_event_class, 'covered']
        ].each do |event_class, expected_alias|
          expect(event_class).to be < EvilEvents::Core::Events::AbstractEvent
          expect(event_class.type).to eq(expected_alias)
          expect(manager_registry.managed_event?(event_class)).to eq(true)
          expect { manager_registry.manager_of_event(event_class) }.not_to raise_error
        end

        expect(manager_registry.size).to eq(2)
      end

      it 'requires event type alias and optional proc with class definitions' do
        expect { described_class.create_class }.to raise_error(ArgumentError)
        expect { described_class.create_class('deleted', double) }.to raise_error(ArgumentError)
        expect { described_class.create_class('destroyed') }.not_to raise_error
        expect { described_class.create_class('ignored', &(proc {})) }.not_to raise_error

        concrete_class = described_class.create_class('tested') do
          payload :a
          payload :b
          payload :c

          observe ->(event) {}
          observe ->(event) {}
        end

        expect { concrete_class.new(payload: { a: '10', b: 20, c: :"30" }) }.not_to raise_error
        expect(concrete_class.observers.size).to eq(2)

        event_instance = concrete_class.new(payload: { a: :a, b: :b, c: :c })
        expect(event_instance).to be_a(concrete_class)
        expect(event_instance).to be_a(events_namespace::AbstractEvent)
      end

      specify 'duplication doesnt affects manager registry and fails with registry error' do
        concrete_event_class   = described_class.create_class('requested')
        concrete_event_manager = manager_registry.manager_of_event(concrete_event_class)

        # try to duplicate: run registration hooks again
        expect { described_class.create_class('requested') }.to(
          raise_error(events_namespace::ManagerRegistry::AlreadyManagedEventClassError)
        )
        # try again
        expect { described_class.create_class('requested') }.to(
          raise_error(events_namespace::ManagerRegistry::AlreadyManagedEventClassError)
        )

        expect(manager_registry.managed_event?(concrete_event_class)).to eq(true)
        expect(manager_registry).to include(concrete_event_manager)
        expect(manager_registry.size).to eq(1)
      end

      specify 'any other errors in event definition doesnt affects manager registry' do
        event_type = gen_str

        # create event class with errors
        expect do
          begin
            described_class.create_class(event_type) { raise ZeroDivisionError }
          rescue ZeroDivisionError
            nil
          end
        end.not_to(change { manager_registry.size })

        # create event class without errors
        expect do
          described_class.create_class(event_type)
        end.to(change { manager_registry.size }.by(1))
      end
    end
  end

  describe 'building of event instances' do
    describe '.restore_instance' do
      let!(:event_class) do
        build_event_class('restore_event') do
          payload :test
          payload :default, EvilEvents::Types::String.default('test')

          metadata :test
          metadata :default, EvilEvents::Types::Int.default(-1)

          adapter :memory_async
        end
      end

      context 'whe id is not provided' do
        it 'returns an event object with consistent data and undefined id attribute' do
          event_attrs = {
            payload:  { test: gen_str },
            metadata: { test: gen_str }
          }

          restored_event = described_class.restore_instance(event_class, **event_attrs)

          expect(restored_event).to have_attributes(
            id: 'unknown',
            type: event_class.type,
            payload: match(event_attrs[:payload].merge(default: 'test')),
            metadata: match(event_attrs[:metadata].merge(default: -1))
          )
        end
      end

      context 'when id is provided' do
        it 'returns an event object with consistent data' do
          event_attrs = {
            id: gen_str,
            payload:  { test: gen_str },
            metadata: { test: gen_str }
          }

          restored_event = described_class.restore_instance(event_class, **event_attrs)

          expect(restored_event).to have_attributes(
            id: event_attrs[:id],
            type: event_class.type,
            payload: match(event_attrs[:payload].merge(default: 'test')),
            metadata: match(event_attrs[:metadata].merge(default: -1))
          )
        end
      end
    end
  end
end
