# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::MessagePack::Engines::Mpacker do
  let(:serialization_state) do
    build_serialization_state(
      id: gen_str,
      type: gen_str,
      payload: { gen_symb => gen_str, gen_symb => gen_str },
      metadata: { gen_symb => gen_str, gen_symb => gen_str }
    )
  end

  let(:engine) do
    config = EvilEvents::Core::Events::Serializers::MessagePack::Config.new
    described_class.new(config)
  end

  describe '#dump' do
    it 'returns a string representation of serialization state' do
      expected = ::MessagePack::Factory.new.packer.pack(
        id:       serialization_state.id,
        type:     serialization_state.type,
        payload:  serialization_state.payload,
        metadata: serialization_state.metadata
      ).to_str

      serialization = engine.dump(serialization_state)

      expect(serialization).to be_a(String)
      expect(serialization).to match(expected)
    end

    it 'each invocation returns new string object' do
      first_serialization  = engine.dump(serialization_state)
      second_serialization = engine.dump(serialization_state)

      expect(first_serialization.object_id).not_to eq(second_serialization.object_id)
    end
  end

  describe '#load' do
    context 'when received object is a correct msgpack string' do
      let(:message) { engine.dump(serialization_state) }

      it 'returns serialization state' do
        state = engine.load(message)

        expect(state).to be_a(EvilEvents::Core::Events::Serializers::Base::EventSerializationState)
        expect(state.id).to eq(serialization_state.id)
        expect(state.type).to eq(serialization_state.type)
        expect(state.payload).to eq(serialization_state.payload)
        expect(state.metadata).to eq(serialization_state.metadata)
      end
    end

    context 'when received object isnt a parsable mpacker string' do
      let(:messages) { gen_all }

      it 'fails with error' do
        messages.each do |message|
          expect { engine.load(message) }.to raise_error(EvilEvents::SerializationEngineError)
        end
      end
    end
  end
end
