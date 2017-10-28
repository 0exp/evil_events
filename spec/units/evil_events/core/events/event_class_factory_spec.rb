# frozen_string_literal: true

describe EvilEvents::Core::Events::EventClassFactory, :stub_event_system do
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
    describe '#create_abstract' do
      include_examples 'shared class construction logic', :create_abstract

      specify 'requires event type alias only (string object)' do
        expect { described_class.create_abstract('user_registered') }.not_to raise_error
        expect { described_class.create_abstract('overwatched', &(proc {})) }.not_to raise_error

        expect { described_class.create_abstract }.to(
          raise_error(ArgumentError)
        )

        expect { described_class.create_abstract('test_event', double) }.to(
          raise_error(ArgumentError)
        )

        expect { described_class.create_abstract(double) }.to(
          raise_error(extensions_namespace::TypeAliasing::IncopatibleEventTypeError)
        )

        expect { described_class.create_abstract(nil) }.to(
          raise_error(extensions_namespace::TypeAliasing::EventTypeNotDefinedError)
        )
      end

      specify 'passed type alias becomes a type alias of a new created abstract class' do
        abstract_event_class = described_class.create_abstract('overwatched')
        expect(abstract_event_class.type).to eq('overwatched')

        abstract_event_class = described_class.create_abstract('healed')
        expect(abstract_event_class.type).to eq('healed')
      end

      it 'doesnt registers new created class in manager regestry' do
        described_class.create_abstract('destroyed')
        expect(event_system.event_manager.manager_registry).to be_empty

        described_class.create_abstract('installed')
        expect(event_system.event_manager.manager_registry).to be_empty
      end

      specify 'descendant of created class automatically registrates in manager registry' do
        abstract_event_class         = described_class.create_abstract('created')
        concrete_event_class         = Class.new(abstract_event_class)

        another_abstract_event_class = described_class.create_abstract('used')
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
        abstract_event_class   = described_class.create_abstract('inherited')
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
    describe '#create' do
      include_examples 'shared class construction logic', :create

      it 'creates a concrete event class with defined type alias and registered manager' do
        concrete_event_class = described_class.create('overwatched')
        another_event_class  = described_class.create('covered')

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
        expect { described_class.create }.to raise_error(ArgumentError)
        expect { described_class.create('deleted', double) }.to raise_error(ArgumentError)
        expect { described_class.create('destroyed') }.not_to raise_error
        expect { described_class.create('ignored', &(proc {})) }.not_to raise_error

        concrete_class = described_class.create('tested') do
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
        concrete_event_class   = described_class.create('requested')
        concrete_event_manager = manager_registry.manager_of_event(concrete_event_class)

        # try to duplicate: run registration hooks again
        expect { described_class.create('requested') }.to(
          raise_error(events_namespace::ManagerRegistry::AlreadyManagedEventClassError)
        )
        # try again
        expect { described_class.create('requested') }.to(
          raise_error(events_namespace::ManagerRegistry::AlreadyManagedEventClassError)
        )

        expect(manager_registry.managed_event?(concrete_event_class)).to eq(true)
        expect(manager_registry).to include(concrete_event_manager)
        expect(manager_registry.size).to eq(1)
      end
    end
  end
end
