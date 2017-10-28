# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Adapters do
  let(:container) { described_class.new }

  it_behaves_like 'dependency container interface'

  describe '#register_core_adapters!' do
    it 'registrates core adapters from Adapters namespace' do
      expect { container.resolve(:memory_sync) }.to  raise_error(Dry::Container::Error)
      expect { container.resolve(:memory_async) }.to raise_error(Dry::Container::Error)

      container.register_core_adapters!

      expect(container.resolve(:memory_sync)).to eq(
        EvilEvents::Core::Broadcasting::Adapters::MemorySync
      )

      expect(container.resolve(:memory_async)).to eq(
        EvilEvents::Core::Broadcasting::Adapters::MemoryAsync
      )
    end
  end
end
