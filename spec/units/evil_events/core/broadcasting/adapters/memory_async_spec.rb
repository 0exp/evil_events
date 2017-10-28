# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Adapters::MemoryAsync, :stub_event_system do
  let(:memory_dispatcher) { described_class }

  it_behaves_like 'event dispatching interface' do
    let(:dispatcher) { memory_dispatcher }
  end

  describe '#call' do
    it 'delegates the processing of the received event to the event dispatcher asynchronously' do
      event = build_event_class('event').new

      # TODO: sorry, need a global ioc container for low-level dependencies
      expect(described_class::AsyncTask).to eq(::Thread)
      stub_const(
        'EvilEvents::Core::Broadcasting::Adapters::MemoryAsync::AsyncTask',
        Concurrent::Future
      )

      expect(EvilEvents::Core::Broadcasting::Dispatcher).not_to(
        receive(:dispatch).with(event).twice
      )

      [
        proc { memory_dispatcher.call(event) },
        proc { memory_dispatcher.call(event) },
        proc { memory_dispatcher.call(event) },
        proc { memory_dispatcher.call(event).execute.value },
        proc { memory_dispatcher.call(event).execute.value }
      ].shuffle.each(&:call)
    end
  end
end
