# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers, :stub_event_system do
  include_context 'event system'

  let(:serializers_container) { described_class.new }

  it_behaves_like 'dependency container interface' do
    let(:container) { serializers_container }
  end

  describe 'common behaviour' do
    before { serializers_container.register_core_serializers! }

    it 'has following registered serializers' do
      expect(serializers_container.resolve(:json)).to    be_a(described_class::JSON)
      expect(serializers_container.resolve(:hash)).to    be_a(described_class::Hash)
    end

    specify 'serializers should be memoized' do
      expect(serializers_container.resolve(:json)).to eq(serializers_container.resolve(:json))
      expect(serializers_container.resolve(:hash)).to eq(serializers_container.resolve(:hash))
    end

    specify 'fails when serialization engine cant be recognized', :stub_event_system do
      system_config.configure { |c| c.serializers.json.engine = gen_symb }

      expect { serializers_container.resolve(:json) }.to raise_error(
        EvilEvents::UnrecognizedSerializationEngineError
      )

      system_config.configure { |c| c.serializers.hashing.engine = gen_symb }
      expect { serializers_container.resolve(:hash) }.to raise_error(
        EvilEvents::UnrecognizedSerializationEngineError
      )

      system_config.configure { |c| c.serializers.msgpack.engine = gen_symb }
      expect { serializers_container.resolve(:msgpack) }.to raise_error(
        EvilEvents::UnrecognizedSerializationEngineError
      )

      system_config.configure { |c| c.serializers.xml.engine = gen_symb }
      expect { serializers_container.resolve(:xml) }.to raise_error(
        EvilEvents::UnrecognizedSerializationEngineError
      )
    end
  end
end
