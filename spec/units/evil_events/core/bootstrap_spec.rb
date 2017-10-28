# frozen_string_literal: true

describe EvilEvents::Core::Bootstrap do
  it_behaves_like 'dependency container interface' do
    let(:container) { described_class }
  end

  describe 'registered dependencies' do
    specify 'event_system' do
      expect(described_class.resolve(:event_system)).to be_a(EvilEvents::Core::System)

      # verify event system memoization
      first_resolve  = described_class.resolve(:event_system)
      second_resolve = described_class.resolve(:event_system)
      expect(first_resolve).to eq(second_resolve)
    end

    specify 'config' do
      expect(described_class.resolve(:config)).to be_a(EvilEvents::Core::Config)
    end
  end
end
