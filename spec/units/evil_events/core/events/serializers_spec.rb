# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers do
  it_behaves_like 'dependency container interface' do
    let(:container) { described_class }
  end

  it 'has following registered serializers' do
    expect(described_class.resolve(:json)).to    be_a(described_class::JSON)
    expect(described_class.resolve(:hash)).to    be_a(described_class::Hash)
    expect(described_class.resolve(:xml)).to     be_a(described_class::XML)
    expect(described_class.resolve(:msgpack)).to be_a(described_class::MessagePack)
  end

  specify 'serializers should be memoized' do
    expect(described_class.resolve(:json)).to    eq(described_class.resolve(:json))
    expect(described_class.resolve(:hash)).to    eq(described_class.resolve(:hash))
    expect(described_class.resolve(:xml)).to     eq(described_class.resolve(:xml))
    expect(described_class.resolve(:msgpack)).to eq(described_class.resolve(:msgpack))
  end
end
