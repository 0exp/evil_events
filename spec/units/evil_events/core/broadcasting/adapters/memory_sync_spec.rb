# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Adapters::MemorySync, :stub_event_system do
  let(:memory_dispatcher) { described_class }

  it_behaves_like 'event dispatching interface' do
    let(:dispatcher) { memory_dispatcher }
  end

  describe '#call' do
    it 'delegates the processing of the received event to the event dispatcher' do
      event = build_event_class('event').new

      expect(EvilEvents::Core::Broadcasting::Dispatcher).to(
        receive(:dispatch).with(event)
      )

      memory_dispatcher.call(event)
    end
  end
end
