# frozen_string_literal: true

describe EvilEvents::Adapters, :stub_event_system do
  include_context 'event system'

  describe '.register' do
    it 'delegates a registration action to the event system' do
      adapter_name   = double
      adapter_object = double

      expect(event_system).to receive(:register_adapter).with(adapter_name, adapter_object).once
      described_class.register(adapter_name, adapter_object)
    end

    it 'registrates new adapter object with passed name' do
      adapter_name   = :test_adapter
      adapter_object = double
      described_class.register(adapter_name, adapter_object)
      expect(event_system.resolve_adapter(adapter_name)).to eq(adapter_object)
    end

    it 'fails when apdater with passed name is already registered' do
      described_class.register(:test_adapter, double)
      expect { described_class.register(:test_adapter, double) }.to(
        raise_error(Dry::Container::Error)
      )

      described_class.register(:another_adapter, double)
      expect { described_class.register(:another_adapter, double) }.to(
        raise_error(Dry::Container::Error)
      )
    end
  end

  describe '.resolve' do
    it 'delegates a recognition action to the event system' do
      adapter_name = double
      expect(event_system).to receive(:resolve_adapter).with(adapter_name)
      described_class.resolve(adapter_name)
    end

    it 'returns adapter object by its name' do
      sidekiq_adapter = double
      que_adapter     = double

      described_class.register(:sidekiq, sidekiq_adapter)
      described_class.register(:que, que_adapter)

      expect(described_class.resolve(:que)).to eq(que_adapter)
      expect(described_class.resolve(:sidekiq)).to eq(sidekiq_adapter)
    end

    it 'fails when event system has no registered adapter with passed name' do
      expect { described_class.resolve(:kek_pek) }.to raise_error(Dry::Container::Error)
      described_class.register(:kek_pek, double)
      expect { described_class.resolve(:kek_pek) }.not_to raise_error
    end
  end
end
