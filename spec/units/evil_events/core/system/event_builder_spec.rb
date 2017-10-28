# frozen_string_literal: true

describe EvilEvents::Core::System::EventBuilder, :stub_event_system do
  include_context 'event system'

  let(:event_type) { 'test_event' }
  let(:event_definitions) do
    proc do
      default_delegator :call
      payload :a, EvilEvents::Types::Any
      payload :b, EvilEvents::Types::String
      observe ::Kernel
      observe ::Object, delegator: :new
      adapter :memory_async
    end
  end

  describe '.define_event_class' do
    it 'delegates non-abstract event class creation to EventClassFactory' do
      expect(EvilEvents::Core::Events::EventClassFactory).to(
        receive(:create).with(event_type).once do |&received_block|
          expect(received_block).to eq(event_definitions)
        end
      )

      described_class.define_event_class(event_type, &event_definitions)
    end

    it 'returns a corret delegation result (registered event class)' do
      event_class = described_class.define_event_class(event_type, &event_definitions)

      expect(event_class).to be < EvilEvents::Core::Events::AbstractEvent
      expect(event_system.managed_event?(event_class)).to eq(true)

      expect { described_class.define_event_class(event_type, &event_definitions) }.to(
        raise_error(EvilEvents::Core::Events::ManagerRegistry::AlreadyManagedEventClassError)
      )
    end

    specify 'required attributes' do
      expect { described_class.define_event_class }.to raise_error(ArgumentError)
      expect { described_class.define_event_class('test', double) }.to raise_error(ArgumentError)
      expect { described_class.define_event_class('suite_event') }.not_to raise_error
      expect { described_class.define_event_class('spec_event', &(proc {})) }.not_to raise_error
    end
  end

  describe '.define_abstract_event_class' do
    it 'delegates abstract event class creation to EventClassFactory' do
      expect(EvilEvents::Core::Events::EventClassFactory).to(
        receive(:create_abstract).with(event_type).once
      )

      described_class.define_abstract_event_class(event_type)
    end

    it 'returns a correct delegation result (unregistered event class)' do
      event_class = described_class.define_abstract_event_class(event_type)

      expect(event_class).to be < EvilEvents::Core::Events::AbstractEvent
      expect(event_system.managed_event?(event_class)).to eq(false)

      expect { described_class.define_event_class(event_type) }.not_to raise_error
      expect(event_system.managed_event?(event_class)).to eq(false)
    end

    specify 'required attributes' do
      expect { described_class.define_event_class }.to raise_error(ArgumentError)
      expect { described_class.define_event_class('test', double) }.to raise_error(ArgumentError)
      expect { described_class.define_event_class('suite_event') }.not_to raise_error
      expect { described_class.define_event_class('spec_event', &(proc {})) }.not_to raise_error
    end
  end
end
