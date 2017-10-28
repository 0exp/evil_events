# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers do
  it_behaves_like 'dependency container interface' do
    let(:container) { described_class }
  end

  it 'has following registered serializers' do
    expect(described_class.resolve(:json)).to eq(described_class::JSON)

    expect(described_class.resolve(:hash)).to eq(described_class::Hash)
  end
end
