# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::XML::Engines::Ox do
  let(:serialization_state) do
    build_serialization_state(
      id: gen_str,
      type: gen_str,
      payload: { gen_symb => gen_str, gen_symb => gen_str },
      metadata: { gen_symb => gen_str, gen_symb => gen_str }
    )
  end

  let(:engine) do
    config = EvilEvents::Core::Events::Serializers::XML::Config.new
    described_class.new(config)
  end

  describe '#dump' do
    it 'returns xml representation of serialization state based on Ox library' do
      expected_xml_string = ::Ox.dump(serialization_state)
      serialization = engine.dump(serialization_state)

      expect(serialization).to be_a(String)
      expect(serialization).to match(expected_xml_string)
    end

    it 'each invocation provides a new xml string' do
      first_serialization  = engine.dump(serialization_state)
      secont_serialization = engine.dump(serialization_state)

      expect(first_serialization.object_id).not_to eq(secont_serialization.object_id)
    end
  end

  describe '#load' do
    context 'when received object is a correct xml string' do
      let(:xml) { engine.dump(serialization_state) }

      it 'returns serialization state' do
        state = engine.load(xml)

        expect(state).to be_a(EvilEvents::Core::Events::Serializers::Base::EventSerializationState)
        expect(state.id).to eq(serialization_state.id)
        expect(state.type).to eq(serialization_state.type)
        expect(state.payload).to eq(serialization_state.payload)
        expect(state.metadata).to eq(serialization_state.metadata)
      end
    end

    context 'when received object isnt a parsable xml string' do
      let(:xmls) { gen_all }

      it 'fails with error' do
        xmls.each do |xml|
          expect { engine.load(xml) }.to raise_error(EvilEvents::SerializationEngineError)
        end
      end
    end
  end
end
